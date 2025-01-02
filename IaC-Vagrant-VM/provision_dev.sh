#!/bin/bash

sudo yum install epel -y
# # Docker CE 설치를 위한 prerequisites 설치
# sudo dnf install -y dnf-plugins-core
sudo yum update
# # Docker 저장소 추가
# sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

# # Docker CE 설치
# sudo dnf install -y docker-ce docker-ce-cli containerd.io

# # Docker 서비스 시작 및 부팅 시 자동 실행 설정
# sudo systemctl start docker
# sudo systemctl enable docker

# # 현재 사용자를 docker 그룹에 추가하여 sudo 없이 docker 명령을 실행할 수 있도록 설정
# sudo usermod -aG docker vagrant

# # Docker 버전 확인
# docker --version

# # Nginx 설치
# sudo dnf install -y nginx

# # Nginx 서비스 시작 및 부팅 시 자동 실행 설정
# sudo systemctl start nginx
# sudo systemctl enable nginx

# # Nginx 상태 확인
# sudo systemctl status nginx

# # Ansible 설치
sudo yum install -y ansible

# # Ansible 버전 확인
ansible --version
