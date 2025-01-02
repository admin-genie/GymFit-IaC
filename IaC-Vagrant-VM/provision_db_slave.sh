#!/bin/bash
sudo yum update
# MySQL 설치

sudo yum install -y mysql-server

# MySQL 서비스 시작 및 부팅 시 자동 실행 설정
sudo systemctl start mysqld
sudo systemctl enable mysqld
