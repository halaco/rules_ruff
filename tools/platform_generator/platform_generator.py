import argparse
import tomllib

from jinja2 import Environment, FileSystemLoader

CPU_PLATFORMS = {
    "x86_64": "@platforms//cpu:x86_64",
    "aarch64": "@platforms//cpu:aarch64",
}

OS_PLATFORMS = {
    "linux-gnu": "@platforms//os:linux",
    "windows-msvc": "@platforms//os:windows",
    "darwin": "@platforms//os:macos",
}


def main():
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
        print(f"Config file '{args.config}' not found.")
        return

    platform_keys = sorted(config_data.get("platforms", {}).keys())

    arch_key = config_data["ruff_release"]["arch_key"]

    platforms = []
    for key in platform_keys:
        platform_data = config_data["platforms"][key]
        arch = platform_data.get("arch", "x86_64")
        os = platform_data.get("os", "linux-gnu")
        ext = platform_data.get("ext", "tar.gz")
        vender = platform_data.get("vender", "unknown")

        platform_key = arch_key.format(arch=arch, os=os, vender=vender)

        platform_param = {
            "key": platform_key,
            "arch": arch,
            "os": os,
            "ext": ext,
            "vender": vender,
            "compatible_os": OS_PLATFORMS.get(os, os),
            "compatible_arch": CPU_PLATFORMS.get(arch, arch),
        }

        platforms.append(platform_param)

    template_params = {
        "name": "RUFF",
        "platforms": platforms,
    }

    env = Environment(loader=FileSystemLoader("tools/platform_generator"))

    template = env.get_template("platforms.bzl.jinja2")

    rendered_content = template.render(template_params)
    rendered_content = rendered_content + "\n"

    output_file = config_data["files"]["platform_file"]
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(rendered_content)


if __name__ == "__main__":
    main()
