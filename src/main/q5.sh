#!/bin/bash
# Q5：运行 launch.env 给定的启动前检查，保存 stdout/stderr、真实退出码和诊断报告。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

# TODO：删除下方提示和 exit 77，再填写你的命令。
source "$input/launch.env"
if bash "$LAUNCH_TOOl" "$MODEL_PATH" "$CAMERA_PATH" \
    > "$output/stdout.log" 2> "$output/stderr.log"; then
    code=0
else
    code=$?
fi
if [ $code -eq 0 ]; then
    result=SUCCESS
    reason=NONE
elif [ $code -eq 10 ]; then
    result=FAILED
    reason=MODEL_MISSING
elif [ $code -eq 20 ]; then
    result=FAILED
    reason=CAMERA_DENIED
fi
printf "%s\n" "$code" > "$output/exit-code.txt"
printf '%s\n' \
    "result=$result" \
    "exit_code=$code" \
    "reason=$reason" > "$output/report.txt"

