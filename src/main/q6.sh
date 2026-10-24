#!/bin/bash
# Q6：将本地 Debian 包安装到 output/sysroot，运行安装后的工具。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

# TODO：删除下方提示和 exit 77，再填写你的命令。
mkdir -p "$output/sysroot"
package="$input/aim-sentry-tools.deb"
dpkg --root="$output/sysroot" --force-no-root --install "$package"
"$output/sysroot/usr/bin/aim-sentry-info" > "$output/tool-output.txt"

