#!/bin/bash
sudo yum update
# MySQL 설치
sudo dnf install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld

# MySQL 보안 설정 및 초기 비밀번호 설정
sudo mysql_secure_installation <<EOF
y ##Validate Password Plugin을 설정
y ##현재 설정된 root 암호를 변경
y ##root 암호 변경을 위해 새 암호를 설정
y ##anonymous 사용자를 삭제
y ##원격 로그인을 허용하는 권한을 제거
EOF

# MySQL 원격 접속을 위한 사용자 및 권한 설정
sudo mysql -e "CREATE USER 'remote_user'@'%' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'remote_user'@'%' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"