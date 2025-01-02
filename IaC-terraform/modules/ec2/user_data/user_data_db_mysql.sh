#!/bin/bash -x

# 시스템 업데이트
sudo dnf update

# 필요한 패키지 설치
sudo dnf install wget openssl-devel -y

# MySQL 8.0 Community Repository 다운로드 및 설치
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-3.noarch.rpm
sudo dnf install mysql80-community-release-el9-3.noarch.rpm -y

# 시스템 업데이트
sudo dnf update -y

# MySQL Community Server 설치
sudo dnf install mysql-community-server -y

sudo systemctl start mysqld
sudo systemctl enable mysqld

# 주석 처리할 라인들
lines_to_comment=(
    "bind-address = 127.0.0.1"
    "mysqlx-bind-address = 127.0.0.1"
)

# 설정 파일 경로
config_file="/etc/my.cnf"

# 설정 파일 백업
cp "$config_file" "$config_file.bak"

# 주석 처리된 설정 파일 생성
for line_to_comment in "${lines_to_comment[@]}"; do
    sed -i "s/^$line_to_comment/#$line_to_comment/" "$config_file"
done
