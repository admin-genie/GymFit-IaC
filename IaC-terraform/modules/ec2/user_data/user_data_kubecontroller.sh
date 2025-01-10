#!/bin/bash -x

# Ansible 설치
sudo yum install ansible -y
ansible --version

# Python3 및 pip 설치
sudo yum install python3-pip -y

# AWS 관련 패키지 설치
sudo pip3 install boto3
sudo pip3 install --upgrade awscli

# Ansible 설정 파일 경로 설정
echo 'export ANSIBLE_CONFIG=/home/ec2-user/.ansible/ansible.cfg' >> /home/ec2-user/.bashrc

# Git 설치
sudo yum install git -y