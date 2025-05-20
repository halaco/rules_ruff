"""This module implements the language-specific toolchain rule.
"""

RuffInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "target_tool_path": "Path to the tool executable for the target platform.",
        "tool_files": """Files required in runfiles to make the tool executable available.

May be empty if the target_tool_path points to a locally installed tool binary.""",
        "is_windows": "True if the target os is windows"
    },
)

def _ruff_toolchain_impl(ctx):
    if ctx.attr.target_tool and ctx.attr.target_tool_path:
        fail("Can only set one of target_tool or target_tool_path but both were set.")
    if not ctx.attr.target_tool and not ctx.attr.target_tool_path:
        fail("Must set one of target_tool or target_tool_path.")

    tool_files = []
    target_tool_path = ctx.attr.target_tool_path

    if ctx.attr.target_tool:
        tool_files = ctx.attr.target_tool.files.to_list()

        # Passing the short_path. This file is referenced during the execution
        # thus it should be in the runfiles.
        target_tool_path = tool_files[0].short_path

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "RUFF_BIN": target_tool_path,
    })
    default = DefaultInfo(
        files = depset(tool_files),
        runfiles = ctx.runfiles(files = tool_files),
    )
    ruffinfo = RuffInfo(
        target_tool_path = target_tool_path,
        tool_files = tool_files,
        is_windows = ctx.attr.is_windows,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        ruffinfo = ruffinfo,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

ruff_toolchain = rule(
    implementation = _ruff_toolchain_impl,
    attrs = {
        "target_tool": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = False,
            allow_single_file = True,
        ),
        "target_tool_path": attr.string(
            doc = "Path to an existing executable for the target platform.",
            mandatory = False,
        ),
        "is_windows": attr.bool(
            doc = "True if the target os is windows",
            mandatory = True,
        )
    },
    doc = """Defines a ruff executable binary toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
