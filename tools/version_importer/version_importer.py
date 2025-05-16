
import argparse
import base64
import re
import requests
import tomllib

def parse_args():
    import argparse

    parser = argparse.ArgumentParser(description="Import version information from a file.")
    parser.add_argument(
        "ruff_version",
        type=str,
        help="ruff version to import.",
    )
    parser.add_argument(
        "--config",
        type=str,
        default="config.toml",
        help="Path to the configuration file.",
    )
    return parser.parse_args()

def sha245_to_sri(hex_hash: str) -> str:
    hash_bytes = bytes.fromhex(hex_hash)
    base64_encoded = base64.b64encode(hash_bytes).decode('ascii')
    return f"sha256-{base64_encoded}"


def fetch_version_integrities(version, config):
    release_info = config["ruff_release"]
    base_url = release_info["base_url"]
    file_template = base_url + release_info["file"] + "." + release_info["hash"]

    integrities = {}
    platforms = config["platforms"]
    for key, value in platforms.items():
        platform_key = "{arch}-{vender}-{os}".format(
            os = value["os"],
            arch = value["arch"],
            vender = value["vender"]
        )
        url = file_template.format(
            version=version,
            os = value["os"],
            arch = value["arch"],
            vender = value["vender"],
            ext = value["ext"]
        )
        print(platform_key)
        print(url)

        response = requests.get(url)
        response.raise_for_status()

        print(f"{response.text}")
        sha256 = response.text.split()[0]
        print(f"SHA256: {sha245_to_sri(sha256)}")
        integrities[platform_key] = sha245_to_sri(sha256)

    return integrities

pattern = r'\s*"(\d+\.\d+\.\d+(?:-[\w\.-]+)?(?:\+[\w\.-]+)?)"\s*:\s*\{'

def read_imported_versions(version_file):
    versions = set()

    with open(version_file, "r") as vf:
        version_info = vf.read()
    for line in version_info.splitlines():
        match = re.search(pattern, line)
        if match:
            version = match.group(1)
            print(f"Found version: {version}")
            # Do something with the version if needed
            versions.add(version)

    print(f"Imported versions: {versions}")
    return versions


def update_version_file(version_file, version, integrities):
    with open(version_file, "r") as vf:
        version_info = vf.read()

    with open(version_file, "w") as vf:
        for line in version_info.splitlines():
            if line.startswith("LATEST_RUFF_VERSION"):
                # Update the latest version
                vf.write(f'LATEST_RUFF_VERSION = "{version}"\n')
            elif line.startswith("RUFF_VERSIONS"):
                vf.write(line + "\n")
                # Add the new version information
                vf.write(f'    "{version}": {{\n')
                for key in sorted(integrities.keys()):
                    vf.write(f'        "{key}": "{integrities[key]}",\n')
                vf.write("    },\n")
            else:
                # Write the original line
                vf.write(line + "\n")


if __name__ == "__main__":
    args = parse_args()

    with open(args.config, "rb") as f:
        config = tomllib.load(f)

    print(config)

    imported_versions = read_imported_versions(config["files"]["version_file"])
    if args.ruff_version in imported_versions:
        print(f"Version {args.ruff_version} already imported.")
        exit(0)

    integrities = fetch_version_integrities(args.ruff_version, config)
    print(f'    "{args.ruff_version}": {{')
    for key in sorted(integrities.keys()):
        print(f'        "{key}": "{integrities[key]}",')
    print("    },")

    update_version_file(config["files"]["version_file"], args.ruff_version, integrities)
