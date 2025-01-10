#!/bin/bash

# Terraform Output 파일(JSON) 생성
terraform output -json >output.json

# Ansible hosts 파일 설정(controller, worker 노드 IP 추가)
cat output.json | jq -r ' .["kube_controller_ip"].value[]' >>user.info
cat output.json | jq -r ' .["kube_controller_ip_c"].value[]' >>user.info
cat output.json | jq -r ' .["kube_worker_ips"].value[]' >>user.info

# SSH keyscan을 위한 IP 목록 파일 생성(Worker 노드 IP 추가)
cat output.json | jq -r ' .["kube_worker_ips"].value[]' >keyscan.info

#변수 세팅
prjt=$(basename $(pwd))
amiUserList=("ec2-user" "ubuntu" "ec2-user")

# Bastion Host OS 선택
echo "현재 BastionHost의 OS를 선택해주세요."
echo "=============================="
echo "1.AMZN2 2.Ubuntu-20.04 3.RHEL9"
echo "=============================="
read -p "번호 입력: " bUserNum
((bUserNum -= 1))
bUser=${amiUserList[$bUserNum]}

# Ansible 사용자 및 IP 정보 가져오기
ansUser=$(sed -n '2s/ansible_user=//p' user.info)
bastionIp=$(cat output.json | jq -r '.["bastion_pub_ip"].value')
ansSrvIp=$(cat output.json | jq -r '.["ans_srv_pvt_ip"].value')

# 로컬 호스트에서 Bastion Host로 SSH 접속 및 파일 전송
ssh-keyscan -t rsa ${bastionIp} >>~/.ssh/known_hosts
scp -i ./.ssh/${prjt}-ec2 ./.ssh/${prjt}-ec2 ${bUser}@${bastionIp}:~/.ssh/
scp -i ./.ssh/${prjt}-ec2 ./user.info ${bUser}@${bastionIp}:~/
scp -i ./.ssh/${prjt}-ec2 ./keyscan.info ${bUser}@${bastionIp}:~/
ssh -i ./.ssh/${prjt}-ec2 ${bUser}@${bastionIp} sudo chmod 400 ./.ssh/${prjt}-ec2

# BastionHost에서 사용할 쉘 파일 생성
echo "#!bin/bash" >bastion.sh
echo "ssh-keyscan -t rsa ${ansSrvIp} > /home/${bUser}/.ssh/known_hosts
" >>bastion.sh
echo "scp -i ./.ssh/${prjt}-ec2 ./.ssh/${prjt}-ec2 ${ansUser}@${ansSrvIp}:~/.ssh/
" >>bastion.sh
echo "scp -i ./.ssh/${prjt}-ec2 ./user.info ${ansUser}@${ansSrvIp}:~/
" >>bastion.sh
echo "scp -i ./.ssh/${prjt}-ec2 ./keyscan.info ${ansUser}@${ansSrvIp}:~/
" >>bastion.sh

# AnsibleServer에서 사용할 쉘 파일 생성
echo 'echo "#!bin/bash" > ansible.sh
' >>bastion.sh
echo "ansUser=${ansUser}
" >>bastion.sh
echo 'echo "cat ./user.info > /etc/ansible/hosts
" >> ansible.sh
' >>bastion.sh
echo "scp -i ./.ssh/${prjt}-ec2 ./ansible.sh ${ansUser}@${ansSrvIp}:~/
" >>bastion.sh
echo "scp -i ./.ssh/${prjt}-ec2 ./keyscan.sh ${ansUser}@${ansSrvIp}:~/
" >>bastion.sh
echo "ssh -i ./.ssh/${prjt}-ec2 ${ansUser}@${ansSrvIp} sudo sh ansible.sh
" >>bastion.sh
echo "ssh -i ./.ssh/${prjt}-ec2 ${ansUser}@${ansSrvIp} sudo sh keyscan.sh
" >>bastion.sh

# ssh-keyscan용 쉘 파일 생성
echo "#!/bin/bash" >keyscan.sh

count=$(wc -l <keyscan.info)
keyscanList=()

for ((i = 1; i <= ${count}; i++)); do
    keyscanList+=("$(sed -n "${i}p" "keyscan.info")")
done

for ((i = 0; i <= ${count-1}; i++)); do
    echo "ssh-keyscan -t rsa ${keyscanList[${i}]} >> /home/${ansUser}/.ssh/known_hosts
    " >>keyscan.sh
done

# localhost keyscan 추가
echo "ssh-keyscan -t rsa localhost >> /home/${ansUser}/.ssh/known_hosts" >>keyscan.sh

# Bastion Host로 쉘 스크립트 전송 및 실행
scp -i ./.ssh/${prjt}-ec2 ./bastion.sh ${bUser}@${bastionIp}:~/
scp -i ./.ssh/${prjt}-ec2 ./keyscan.sh ${bUser}@${bastionIp}:~/
ssh -i ./.ssh/${prjt}-ec2 ${bUser}@${bastionIp} sh bastion.sh