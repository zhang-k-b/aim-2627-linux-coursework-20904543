#!/bin/bash
# Q7：读取 input/remote.env，生成 ssh_config，用 SSH 和 SCP 获取远程数据。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

# TODO：删除下方提示和 exit 77，再填写你的命令。
ssh_config="$output/ssh_config"
name="aim-sentry"
source "$input/remote.env"

cat > "$ssh_config" <<EOF
Host $name
    HostName "$HOST"
    User "$REMOTE_USER"
    Port "$PORT"
    IdentityFile "$KEY_PATH"
    UserKnownHostsFile "$KNOWN_HOSTS"
    IdentitiesOnly yes
    StrictHostKeyChecking yes
    BatchMode yes
EOF
chmod 600 "$ssh_config"
ssh -F "$ssh_config" "$name" whoami > "$output/remote-user.txt"
mkdir -p "$output/received"
scp -F "$ssh_config" "$name:$REMOTE_LOG" "$output/received/errors.log"

