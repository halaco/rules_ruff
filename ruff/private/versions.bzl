"""Mirror of release info

This file is a mirror of the release info from the ruff repository.
Run the following command to add the integrity hashes for a new version:
 $ bazel run //tools/version_importer -- <ruff version>
"""

BINARY_FILE_BASE_URL = "https://github.com/astral-sh/ruff/releases/download/"
BINARY_FILE_TEMPLATE = "{version}/ruff-{arch}-{vender}-{os}.{ext}"

RUFF_LAST_VERSIONS = "0.11.10"

# The integrity hashes
RUFF_VERSIONS = {
    "0.11.10": {
        "aarch64-unknown-linux-gnu": "sha256-o5/4G/4CPVUAiUPxEiHUl1nXO5/mv3ZYRibPzdM9hoQ=",
        "aarch64-apple-darwin": "sha256-HEGHxezXZTW3bpka8RFNnJlH/mnm0aacntZyPWd3pT4=",
        "x86_64-unknown-linux-gnu": "sha256-reRYY3q+Bv9ngOCzpf3SgdpVLTPrdblU/ConJ4JYuFY=",
        "x86_64-apple-darwin": "sha256-JfCouBnqXJN3vgL9mMNj/7VlnDU1iIGhzpCfMLNiyzk=",
        "x86_64-pc-windows-msvc": "sha256-13vE7NsPUPWnBCLbkOxzXK9xw+o+IB5uhKeP7WlaSVA=",
    },
    "0.11.9": {
        "aarch64-unknown-linux-gnu": "sha256-jf+0R+4HQF3LCTlmZwOlOsONZwOrvkjbbV7IGJVE3Tc=",
        "aarch64-apple-darwin": "sha256-15VdjPC5ZHF1fZczshV2sAuuvswFbjOC1wI/CSv6hSY=",
        "x86_64-unknown-linux-gnu": "sha256-J29rko9hckslXgTn47nmhZ+G9O7F0bkGpymD8zZbZnE=",
        "x86_64-apple-darwin": "sha256-iNXFRKxKQgs8WOCoWKeAfFRWaKaj+55UA61zqg1VtlM=",
        "x86_64-pc-windows-msvc": "sha256-s8cUTUCzhgsQTLiOXIqVoya4Gz0wW5tqLOMEdhuFCMM=",
    },
    "0.11.8": {
        "aarch64-unknown-linux-gnu": "sha256-pgENk5PiVMc8gamUL9HUnG0QYahL924CRieSSt/dnpk=",
        "aarch64-apple-darwin": "sha256-vD/GaTQ376sa3T8ojW0W+saSbmiIwedY7BYtW2/pCZ0=",
        "x86_64-unknown-linux-gnu": "sha256-jtx6KLuVivTr+2qFACyM2W2I8mTdjAgOBlpumEljzjw=",
        "x86_64-apple-darwin": "sha256-VursrV1OQdL3mbu3BdgyOENt5KVH5dBMBZGuNCKuYcw=",
        "x86_64-pc-windows-msvc": "sha256-InnxetdHS5oUk+wqq0BObxEJJy0yIaXTjuBs6w5MYQA=",
    },
}
