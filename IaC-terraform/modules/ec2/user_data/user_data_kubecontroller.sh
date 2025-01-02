#!/bin/bash -x
sudo yum install ansible -y
ansible --version
sudo yum install python3-pip -y
sudo pip3 install boto3
sudo pip3 install --upgrade awscli

echo 'export ANSIBLE_CONFIG=/home/ec2-user/.ansible/ansible.cfg' >>/home/ec2-user/.bashrc
sudo yum install git -y
