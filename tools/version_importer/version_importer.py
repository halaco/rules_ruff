import argparse
import base64
import logging
import re
import tomllib

import requests
from jinja2 import Environment, FileSystemLoader
from packaging.version import Version

logger = logging.getLogger(__name__)


def read_old_versions_file(config_data):
    """Extracts old versions and their integrity values from the version file specified in the
       config data.
    Args:
        config_data (dict): Configuration data containing the path to the version file.
    Returns:
        dict: A dictionary where keys are version strings and values are lists of tuples
        containing platform and integrity.
    """
    input_file = config_data["files"]["version_file"]

    # Regular expressions to match version and integrity line
    version_pattern = re.compile(
        r'^\s*"([0-9]+\.[0-9]+\.[0-9]+(?:-[\w\.\-]+)?(?:\+[\w\.\-]+)?)"\s*:\s*\{'
    )
    integrity_pattern = re.compile(
        r'^\s*"(?P<platform>[\w\-]+)":\s*"(?P<integrity>\w+-[\w+/=]+)",?\s*$'
    )

    version = None
    versions = {}
    # Read the version file specified in the config data
    with open(input_file, "r", encoding="utf-8") as file:
        for line in file:
            line = line.strip()

            # Check for version line
            match = version_pattern.match(line)
            if match:
                version = match.group(1)
                # Save the integrity values into the list to keep the order in which they appear
                versions[version] = []

            # Check for integrity line
            match = integrity_pattern.match(line)
            if match:
                if version is not None:
                    # Add the platform and integrity to the list for the current version
                    platform = match.group("platform")
                    integrity = match.group("integrity")
                    versions[version].append((platform, integrity))

    return versions


version_prefix_pattern = re.compile(
    r"[A-Za-z]+([0-9]+\.[0-9]+\.[0-9]+(?:-[\w\.\-]+)?(?:\+[\w\.\-]+)?)"
)


def semantic_version(version):
    """Extracts the semantic version from a given version string.
    Args:
        version (str): The version string to extract the semantic version from.
    Returns:
        str: The semantic version extracted from the version string.
    """
    match = version_prefix_pattern.match(version)
    if match:
        return match.group(1)
    return version


def fetch_ruff_releases(config_data):
    owner = "astral-sh"
    repo = "ruff"
    min_version = semantic_version(config_data["ruff_release"]["min_version"])

    url = f"https://api.github.com/repos/{owner}/{repo}/releases"
    tags = []

    page = 1
    exit = False
    while not exit:
        response = requests.get(url, params={"page": page, "per_page": 100})
        if response.status_code != 200:
            raise Exception(
                f"Failed to fetch releases: {response.status_code} {response.text}"
            )

        releases = response.json()
        if not releases:
            break

        for release in releases:
            tag_name = release["tag_name"]
            if Version(semantic_version(tag_name)) < Version(min_version):
                exit = True
                break
            tags.append(tag_name)
        page += 1

    return tags


def generate_sri_from_hex_sha256(hex_hash):
    """Generates a Subresource Integrity (SRI) string from a SHA-256 hex hash.
    Args:
        hex_hash (str): The SHA-256 hash in hexadecimal format.
    Returns:
        str: The SRI string in the format "sha256-<base64_encoded_hash>".
    """
    hash_bytes = bytes.fromhex(hex_hash)
    base64_encoded = base64.b64encode(hash_bytes).decode("ascii")
    return f"sha256-{base64_encoded}"


def fetch_version_integrities(version, config_data):
    base_url = config_data["ruff_release"]["base_url"]
    file_template = config_data["ruff_release"]["file"]

    platforms = config_data["platforms"]
    platform_keys = sorted(platforms.keys())
    integrities = []
    for key in platform_keys:
        platform_data = platforms[key]
        arch = platform_data.get("arch", "x86_64")
        os = platform_data.get("os", "linux-gnu")
        ext = platform_data.get("ext", "tar.gz")
        vender = platform_data.get("vender", "unknown")

        arch_key = config_data["ruff_release"]["arch_key"]
        key = arch_key.format(arch=arch, os=os, vender=vender)

        file_name = file_template.format(
            version=version, arch=arch, os=os, ext=ext, vender=vender
        )
        url = f"{base_url}/{file_name}.sha256"

        response = requests.get(url)
        if response.status_code != 200:
            raise Exception(
                f"Failed to fetch file: {response.status_code} {response.text}"
            )

        # Raise an exception for HTTP errors (e.g. 404, 500, etc.)
        response.raise_for_status()

        integrity = generate_sri_from_hex_sha256(response.text.split(" ")[0])

        integrities.append((key, integrity))

    return integrities


def write_versions_file(config_data, versions):
    """Generates a versions.bzl file from the extracted versions and writes it to the specified
        output file.
    Args:
        config_data (dict): Configuration data containing the output file path and base URL.
        versions (dict): A dictionary where keys are version strings and values are lists of tuples
                        containing platform and integrity.
    Returns:
        None: Writes the rendered content to the output file.
    """
    output_file = config_data["files"]["version_file"]

    sorted_versions = sorted(versions.keys(), key=Version, reverse=True)

    version_params = []
    for version in sorted_versions:
        version_data = versions[version]
        platforms = []
        for platform, integrity in version_data:
            platform_param = {
                "key": platform,
                "integrity": integrity,
            }
            platforms.append(platform_param)

        version_param = {
            "number": version,
            "platforms": platforms,
        }
        version_params.append(version_param)

    template_params = {
        "name": "RUFF",
        "name_lower": "ruff",
        "base_url": config_data["ruff_release"]["base_url"],
        "file_template": config_data["ruff_release"]["file"],
        "latest_version": max(sorted_versions, key=Version),
        "versions": version_params,
    }

    sorted_versions = sorted(versions.keys(), key=Version, reverse=True)

    env = Environment(loader=FileSystemLoader("tools/version_importer"))

    template = env.get_template("versions.bzl.jinja2")

    rendered_content = template.render(template_params)
    rendered_content = rendered_content + "\n"

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(rendered_content)


def main():
    """Main function to parse arguments and load configuration."""

    parser = argparse.ArgumentParser(
        description="Generate platform configuration for RUFF"
    )

    parser.add_argument(
        "--config", type=str, default="config.toml", help="Path to the config file"
    )

    args = parser.parse_args()
    try:
        with open(args.config, "rb") as f:
            config_data = tomllib.load(f)
    except FileNotFoundError:
        logger.error(f"Config file '{args.config}' not found.")
        return

    versions = read_old_versions_file(config_data)

    released_versions = fetch_ruff_releases(config_data)

    for version in released_versions:
        if version not in versions:
            integrities = fetch_version_integrities(version, config_data)
            versions[version] = integrities

    write_versions_file(config_data, versions)


if __name__ == "__main__":
    main()
