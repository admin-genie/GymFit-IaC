#!/bin/bash -x

# LibreSwan 설치
yum install libreswan -y

# IP 포워딩 활성화
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf 

# Reverse Path Filtering 비활성화
echo "net.ipv4.conf.default.rp_filter = 0" >> /etc/sysctl.conf 

# Source Route 허용 비활성화
echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf 

sysctl -p  # sysctl 설정 적용

# 네트워크 서비스 재시작
systemctl restart network 