<!-- Generated with Stardoc: http://skydoc.bazel.build -->


This module defines ruff toolchain registration and testing rules.


<a id="ruff_check_fix"></a>

## ruff_check_fix

<pre>
ruff_check_fix(<a href="#ruff_check_fix-name">name</a>, <a href="#ruff_check_fix-config">config</a>, <a href="#ruff_check_fix-ignore">ignore</a>, <a href="#ruff_check_fix-requirements">requirements</a>, <a href="#ruff_check_fix-select">select</a>, <a href="#ruff_check_fix-srcs">srcs</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ruff_check_fix-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="ruff_check_fix-config"></a>config |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="ruff_check_fix-ignore"></a>ignore |  -   | List of strings | optional | <code>[]</code> |
| <a id="ruff_check_fix-requirements"></a>requirements |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="ruff_check_fix-select"></a>select |  -   | List of strings | optional | <code>[]</code> |
| <a id="ruff_check_fix-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |


<a id="ruff_check_test"></a>

## ruff_check_test

<pre>
ruff_check_test(<a href="#ruff_check_test-name">name</a>, <a href="#ruff_check_test-config">config</a>, <a href="#ruff_check_test-ignore">ignore</a>, <a href="#ruff_check_test-requirements">requirements</a>, <a href="#ruff_check_test-select">select</a>, <a href="#ruff_check_test-srcs">srcs</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ruff_check_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="ruff_check_test-config"></a>config |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |
| <a id="ruff_check_test-ignore"></a>ignore |  -   | List of strings | optional | <code>[]</code> |
| <a id="ruff_check_test-requirements"></a>requirements |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="ruff_check_test-select"></a>select |  -   | List of strings | optional | <code>[]</code> |
| <a id="ruff_check_test-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |


<a id="ruff_format_fix"></a>

## ruff_format_fix

<pre>
ruff_format_fix(<a href="#ruff_format_fix-name">name</a>, <a href="#ruff_format_fix-requirements">requirements</a>, <a href="#ruff_format_fix-srcs">srcs</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ruff_format_fix-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="ruff_format_fix-requirements"></a>requirements |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="ruff_format_fix-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |


<a id="ruff_format_test"></a>

## ruff_format_test

<pre>
ruff_format_test(<a href="#ruff_format_test-name">name</a>, <a href="#ruff_format_test-requirements">requirements</a>, <a href="#ruff_format_test-srcs">srcs</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="ruff_format_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="ruff_format_test-requirements"></a>requirements |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |
| <a id="ruff_format_test-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | <code>[]</code> |


