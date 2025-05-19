"""
This module defines Bazel rules for integrating Ruff, a Python linter and formatter.
"""

def _ruff_check_impl(ctx, extra_flag):
    ruffinfo = ctx.toolchains["//ruff:toolchain_type"].ruffinfo
    default_info = ctx.toolchains["//ruff:toolchain_type"].default

    ruff_exe = ruffinfo.target_tool_path
    if ruff_exe.startswith("external/"):
        ruff_exe = ruff_exe.replace("external/", "../")

    if ctx.attr.select:
        select = "".join(["--select=", ",".join(ctx.attr.select)])
    else:
        select = ""

    if ctx.attr.ignore:
        ignore = "".join(["--ignore=", ",".join(ctx.attr.ignore)])
    else:
        ignore = ""

    if ctx.attr.config:
        if ignore != "" or select != "":
            fail("You cannot use --config with --select or --ignore")
        config = "--config " + ctx.file.config.short_path
    else:
        config = ""

    command = "{ruff_exe} check {paths} {select} {ignore} {config} {extra_flag}".format(
        ruff_exe = ruff_exe,
        paths = " ".join([f.short_path for f in ctx.files.srcs]),
        select = select,
        ignore = ignore,
        config = config,
        extra_flag = extra_flag,
    )

    exe_file = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = exe_file,
        content = command,
    )
    runfiles = ctx.runfiles(
        files = ctx.files.srcs,
    )
    if ctx.attr.config:
        runfiles = runfiles.merge(
            ctx.runfiles(files = [ctx.file.config]),
        )
    runfiles = runfiles.merge(
        ctx.runfiles(transitive_files = default_info.files),
    )

    return DefaultInfo(
        runfiles = runfiles,
        executable = exe_file,
    )

def _ruff_check_test_impl(ctx):
    return _ruff_check_impl(ctx, "--unsafe-fixes")

ruff_check_test = rule(
    implementation = _ruff_check_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "select": attr.string_list(default = []),
        "ignore": attr.string_list(default = []),
        "config": attr.label(default = None, allow_single_file = True),
        "requirements": attr.label_list(allow_files = True),
    },
    toolchains = ["//ruff:toolchain_type"],
)

def _ruff_check_fix_impl(ctx):
    return _ruff_check_impl(ctx, "--unsafe-fixes --fix")

ruff_check_fix = rule(
    implementation = _ruff_check_fix_impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "select": attr.string_list(default = []),
        "ignore": attr.string_list(default = []),
        "config": attr.label(default = None, allow_single_file = True),
        "requirements": attr.label_list(allow_files = True),
    },
    toolchains = ["//ruff:toolchain_type"],
)

def _ruff_format_impl(ctx, extra_flag):
    ruffinfo = ctx.toolchains["//ruff:toolchain_type"].ruffinfo
    default_info = ctx.toolchains["//ruff:toolchain_type"].default

    ruff_exe = ruffinfo.target_tool_path
    if ruff_exe.startswith("external/"):
        ruff_exe = ruff_exe.replace("external/", "../")

    command = "{ruff_exe} format {extra_flag} {paths}".format(
        ruff_exe = ruff_exe,
        paths = " ".join([f.short_path for f in ctx.files.srcs]),
        extra_flag = extra_flag,
    )
    exe_file = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = exe_file,
        content = command,
    )

    runfiles = ctx.runfiles(
        files = ctx.files.srcs,
    )
    runfiles = runfiles.merge(
        ctx.runfiles(transitive_files = default_info.files),
    )

    return DefaultInfo(
        runfiles = runfiles,
        executable = exe_file,
    )

def _ruff_format_test_impl(ctx):
    return _ruff_format_impl(ctx, "--check --diff")

ruff_format_test = rule(
    implementation = _ruff_format_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "requirements": attr.label_list(allow_files = True),
    },
    toolchains = ["//ruff:toolchain_type"],
)

def _ruff_format_fix_impl(ctx):
    return _ruff_format_impl(ctx, "")

ruff_format_fix = rule(
    implementation = _ruff_format_fix_impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "requirements": attr.label_list(allow_files = True),
    },
    toolchains = ["//ruff:toolchain_type"],
)
