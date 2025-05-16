"""Mirror of ruff release info

New releases is added by running the following command:
    $ bazel run //tools:vversion_importer -- <ruff_version>"""

LATEST_RUFF_VERSION = "0.11.10"

RUFF_VERSIONS = {
    "0.11.10": {
        "aarch64-apple-darwin": "sha256-HEGHxezXZTW3bpka8RFNnJlH/mnm0aacntZyPWd3pT4=",
        "aarch64-unknown-linux-gnu": "sha256-o5/4G/4CPVUAiUPxEiHUl1nXO5/mv3ZYRibPzdM9hoQ=",
        "x86_64-apple-darwin": "sha256-JfCouBnqXJN3vgL9mMNj/7VlnDU1iIGhzpCfMLNiyzk=",
        "x86_64-unknown-linux-gnu": "sha256-reRYY3q+Bv9ngOCzpf3SgdpVLTPrdblU/ConJ4JYuFY=",
    },
    "0.11.9": {
        "aarch64-apple-darwin": "sha256-15VdjPC5ZHF1fZczshV2sAuuvswFbjOC1wI/CSv6hSY=",
        "aarch64-unknown-linux-gnu": "sha256-jf+0R+4HQF3LCTlmZwOlOsONZwOrvkjbbV7IGJVE3Tc=",
        "x86_64-apple-darwin": "sha256-iNXFRKxKQgs8WOCoWKeAfFRWaKaj+55UA61zqg1VtlM=",
        "x86_64-unknown-linux-gnu": "sha256-J29rko9hckslXgTn47nmhZ+G9O7F0bkGpymD8zZbZnE=",
    },
    "0.11.8": {
        "aarch64-apple-darwin": "sha256-vD/GaTQ376sa3T8ojW0W+saSbmiIwedY7BYtW2/pCZ0=",
        "aarch64-unknown-linux-gnu": "sha256-pgENk5PiVMc8gamUL9HUnG0QYahL924CRieSSt/dnpk=",
        "x86_64-apple-darwin": "sha256-VursrV1OQdL3mbu3BdgyOENt5KVH5dBMBZGuNCKuYcw=",
        "x86_64-unknown-linux-gnu": "sha256-jtx6KLuVivTr+2qFACyM2W2I8mTdjAgOBlpumEljzjw=",
    },
}
