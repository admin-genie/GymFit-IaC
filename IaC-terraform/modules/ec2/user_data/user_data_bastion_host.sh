#!/bin/bash

# SSH 서버 구성 파일 경로
ssh_config="/etc/ssh/sshd_config"

# 백업 파일 경로
backup_file="$ssh_config.backup"

# SSH 설정 파일 백업
sudo cp "$ssh_config" "$backup_file"

# GatewayPorts 옵션 확인 및 수정
gateway_ports_status=$(grep -E "^\s*#?\s*GatewayPorts\s+" "$ssh_config")
if [ -z "$gateway_ports_status" ]; then
    echo "GatewayPorts yes" | sudo tee -a "$ssh_config" >/dev/null  # GatewayPorts 옵션이 없다면 추가
else
    sudo sed -i 's/^\s*#?\s*GatewayPorts\s\+.*/GatewayPorts yes/' "$ssh_config"
fi

# SSH 서버 재시작
sudo systemctl restart sshd