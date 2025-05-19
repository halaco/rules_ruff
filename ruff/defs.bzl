"""
This module defines ruff toolchain registration and testing rules.
"""

load(
    "//ruff/private:rules_ruff.bzl",
    _ruff_check_fix = "ruff_check_fix",
    _ruff_check_test = "ruff_check_test",
    _ruff_format_fix = "ruff_format_fix",
    _ruff_format_test = "ruff_format_test",
)

ruff_check_test = _ruff_check_test
ruff_format_test = _ruff_format_test
ruff_check_fix = _ruff_check_fix
ruff_format_fix = _ruff_format_fix
