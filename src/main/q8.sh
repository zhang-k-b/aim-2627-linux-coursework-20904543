#!/bin/bash
# Q8：repair 时识别并停止采集器、修复 HTTP 服务；cleanup 时停止修复后的服务。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

action=${3:-repair}

# TODO：删除下方提示和 exit 77，再填写你的命令。
if [[ "$action" == "repair" ]]; then
    source "$input/process.env"
    pid=$(ps -p "$TARGET_PID" -o pid=)
    user=$(ps -p "$TARGET_PID" -o user=)
    state=$(ps -p "$TARGET_PID" -o stat=)
    command=$(ps -ww -p "$TARGET_PID" -o args=)
    if [[ "$command" != *"$TARGET_TOKEN"* ]]; then
        echo "Target token not found in command" >&2
        exit 1
    fi
    printf 'pid=%s\n' "$pid" > "$output/process.txt"
    printf 'user=%s\n' "$user" >> "$output/process.txt"
    printf 'state=%s\n' "$state" >> "$output/process.txt"
    printf 'command=%s\n' "$command" >> "$output/process.txt"

    for round in 1 2 3; do
        if grep -F "TICK" "$WORKER_LOG" > "$output/collector-sample.log"; then
            count=$(wc -l < "$output/collector-sample.log")
        else
            count=0
        fi

        if [[ "$count" -ge 2 ]]; then
            break
        fi
        sleep 0.2
    done
    if [[ "$count" -lt 2 ]]; then
        echo "Collector did not produce enough TICK entries" >&2
        exit 1
    fi
    kill -TERM "$TARGET_PID"
    stopped=0
    for attempt in 1 2 3 4 5; do
        if state_now=$(ps -p "$TARGET_PID" -o stat=); then
            if [[ "$state_now" == Z* ]]; then
                stopped=1
                break
            fi
        else
            stopped=1
            break
        fi
        sleep 0.2
    done
    if [[ "${stopped:-0}" -ne 1 ]]; then
        echo "Failed to stop the target process" >&2
        exit 1
    fi
    kill -TERM "$SERVICE_PID"
elif [[ "$action" == "cleanup" ]]; then
:
fi

