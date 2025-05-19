"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@io_halaco_rules_ruff//ruff:defs.bzl", "ruff_check_fix", "ruff_check_test", "ruff_format_fix", "ruff_format_test")

build_test(
    name = "smoke_test",
    targets = [
        ":ruff_check_test",
        ":ruff_format_test",
        ":ruff_check_fix",
        ":ruff_format_fix",
    ],
)

exports_files(["ruff_config.toml"])

ruff_check_test(
    name = "ruff_check_test",
    size = "small",
    srcs = glob(["*.py"]),
    config = "//:ruff_config.toml",
)

ruff_format_test(
    name = "ruff_format_test",
    size = "small",
    srcs = glob(["*.py"]),
)

ruff_check_fix(
    name = "ruff_check_fix",
    srcs = glob(["*.py"]),
    config = "//:ruff_config.toml",
)

ruff_format_fix(
    name = "ruff_format_fix",
    srcs = glob(["*.py"]),
)
