#!/bin/bash

#AWS 가용리전 목록 불러오기
aws ec2 describe-regions --query "Regions[].{RegionName: RegionName}" --output text > regions.info

#현재 디렉토리명을 프로젝트명으로 사용
prjt=$(basename $(pwd))

#유저이름 구분용 배열 선언
amiList=("AL2023" "Ubuntu20.4" "RHEL9")
amiUserList=("ec2-user" "ubuntu" "ec2-user")

#루프문 시작
while :
do

#Provider 선택
echo "환경을 선택해주세요."
echo "1.AWS 2.NaverCloud"
read cloud
if [ $cloud == "1" ];then
	echo "=====가용리전목록====="
	cat -n "regions.info"
	echo "===================="
	read -p "번호를 입력해주세요: " region_choice
	region=$(sed -n "${region_choice}p" "regions.info")
	cat <<EOF > main.tf
# Terraform Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.1"
    }
  }
    backend "s3" {
    bucket = "gf-prd-tfstate-s3-04301704"
    key    = "terraform.tfstate"
    region = "sa-east-1"
    #    dynamodb_table = "terraform-lock" # s3 bucket을 이용한 협업을 위해 설정 
  }
}
# resource "aws_s3_bucket" "tf_backend" {
#   count  = terraform.workspace == "default" ? 1 : 0 # workspace가 default일 때만 실행해라
#   bucket = "gf-prd-tfstate-s3-04301704"
#   # versioning {                   # deprecated된 문법으로 사용이 가능하긴 하나 권장하지 않음, 자체모듈에서 삭제시 업데이트 필요
#   #   enabled = true
#   # }
#   tags = {
#     Name = "gf-prd-tfstate-s3-04301704"
#   }
# }

# resource "aws_s3_bucket_acl" "tf_backend_acl" {
#   count  = terraform.workspace == "default" ? 1 : 0 # workspace가 default일 때만 실행해라
#   bucket = aws_s3_bucket.tf_backend[0].id
#   acl    = "private"
# }


# Configure AWS Provider
provider "aws" {
  region = "$region"
}
EOF
elif [ $cloud == "2" ];then
	echo "아직 지원되지 않는 Provider 입니다."
	break
fi

#가용영역 설정
aws ec2 describe-availability-zones --region $region --query "AvailabilityZones[].{ZoneName: ZoneName}" --output text  > azs.info
echo "=====가용영역목록====="
cat -n "azs.info"
echo "===================="
read -p "첫번째 가용영역 선택: " azs_choice1
read -p "두번째 가용영역 선택: " azs_choice2
azs1=$(sed -n "${azs_choice1}p" "azs.info")
sed -i "s/az-1 = \"[^\"]*\"/az-1 = \"$azs1\"/g" ./modules/vpc/main.tf
azs2=$(sed -n "${azs_choice2}p" "azs.info")
sed -i "s/az-2 = \"[^\"]*\"/az-2 = \"$azs2\"/g" ./modules/vpc/main.tf

#VPC 대역 설정
vpcCidr="10.0.0.0/16"
read -p "VPC IP 대역 설정[Default:10.0.0.0/16]: " vpcCidrInput
echo $vpcCidrInput
if [ -n "$vpcCidrInput" ];then
	vpcCidr="$vpcCidrInput"
fi

cat <<EOF >> main.tf

# VPC Count
module "main_vpc" {
  source     = "./modules/vpc"
  naming     = "$prjt"
  cidrBlock = "$vpcCidr"
}
EOF

#BastionHost 보안그룹 설정
read -p "BastionHost SSH 보안그룹 IP 자동설정[y/n]: " sgAuto
if [ $sgAuto == "y" ];then
	curl ifconfig.me | grep -oE '[^%]*' > myIp.info
	myIp=$(cat myIp.info)
elif [ $sgAuto == "n" ];then
	echo "BastionHost SSH 보안그룹에 등록할 IP 입력"
	read -p "> " inputIp
	myIp=$inputIp
fi


cat <<EOF >> main.tf
# sg module set
module "sg" {
  source    = "./modules/sg"
  naming    = "$prjt"
  cidrBlock = "$vpcCidr"
  kube_controller_ingress_rules = var.kube_controller_ingress_rules
  kube_worker_ingress_rules     = var.kube_worker_ingress_rules
  defVpcId      = module.main_vpc.def_vpc_id
  myIp = "$myIp/32"
}
EOF

#키페어 생성
echo "==========키페어 생성=========="
keyName="$prjt-ec2"
mkdir ./.ssh
ssh-keygen -t rsa -b 4096 -C "" -f "./.ssh/$keyName" -N ""

#인스턴스 관련
aws ec2 describe-instance-type-offerings --location-type "availability-zone" --region $region --query "InstanceTypeOfferings[?starts_with(InstanceType, 't3')].[InstanceType]" --output text | sort | uniq > instance.info

read -p "ami 게시자 선택[Default: amazon]: " ownerInput
#BastionHost
echo "BastionHost AMI 선택"
echo "=============================="
echo "1.AL2023 2.Ubuntu-20.04 3.RHEL9"
echo "=============================="
read -p "번호 입력: " amiNum
((amiNum-=1))
bUser="${amiUserList[${amiNum}]}"
((amiNum+=1))
amiName=$(sed -n "${amiNum}p" "amiName.data")
aws ec2 describe-images \
--owners amazon \
--filters "Name=name,Values=$amiName" "Name=state,Values=available" \
--query "reverse(sort_by(Images, &Name))[:1].ImageId" \
--region "$region" \
--output text > ami.info
bAmi=$(sed -n "1p" "ami.info")

#Ansible-Server
echo "컨트롤플레인 AMI 선택"
echo "=============================="
echo "1.AL2023 2.Ubuntu-20.04 3.RHEL9"
echo "=============================="
read -p "번호 입력: " amiNum
((amiNum-=1))
srvUser="${amiUserList[${amiNum}]}"
((amiNum+=1))
amiName=$(sed -n "${amiNum}p" "amiName.data")
aws ec2 describe-images \
--owners amazon \
--filters "Name=name,Values=$amiName" "Name=state,Values=available" \
--query "reverse(sort_by(Images, &Name))[:1].ImageId" \
--region "$region" \
--output text >> ami.info
srvAmi=$(sed -n "2p" "ami.info")


srvCount=3
echo "컨트롤플레인 사양 선택"
echo "===================="
cat -n "instance.info"
echo "===================="
read -p "번호를 선택해주세요: " srvTypeSelect
srvType=$(sed -n "${srvTypeSelect}p" "instance.info")
read -p "컨트롤플레인 볼륨 크기[최소:20,최대:30]: " srvVolume
read -p "컨트롤 플레인 갯수:[최소:3] " srvCount
#Ansible-Node
echo "워커 노드 AMI 선택"
echo "=============================="
echo "1.AL2023 2.Ubuntu-20.04 3.RHEL9"
echo "=============================="
read -p "번호 입력: " amiNum
((amiNum-=1))
nodUser="${amiUserList[${amiNum}]}"
((amiNum+=1))
amiName=$(sed -n "${amiNum}p" "amiName.data")
aws ec2 describe-images \
--owners amazon \
--filters "Name=name,Values=$amiName" "Name=state,Values=available" \
--query "reverse(sort_by(Images, &Name))[:1].ImageId" \
--region "$region" \
--output text >> ami.info
nodAmi=$(sed -n "3p" "ami.info")

echo "워커 노드 사양 선택"
echo "===================="
cat -n "instance.info"
echo "===================="
read -p "번호를 선택해주세요: " nodTypeSelect
nodType=$(sed -n "${nodTypeSelect}p" "instance.info")
read -p "워커 노드 볼륨 크기[최소:10,최대:30]: " nodVolume
read -p "워커 노드 수량: " nodCount

# Ansible용 파일 생성
if [ ${srvUser} == ${nodUser} ];then
    echo "[all:vars]
ansible_user=${srvUser}
ansible_ssh_private_key_file=/home/${srvUser}/.ssh/${prjt}-ec2

[${srvUser}]
localhost
" > user.info
else
    echo "[${srvUser}:vars]
ansible_user=${srvUser}
ansible_ssh_private_key_file=/home/${srvUser}/.ssh/${prjt}-ec2

[${srvUser}]
localhost

[${nodUser}:vars]
ansible_user=${nodUser}
ansible_ssh_private_key_file=/home/${srvUser}/.ssh/${prjt}-ec2

[${nodUser}]" > user.info
fi

cat <<EOF >> main.tf

# Instance
module "instance" {
  source        = "./modules/ec2"
  naming        = "$prjt"
  myIp          = "$myIp/32"
  defVpcId      = module.main_vpc.def_vpc_id
  cidrBlock     = "$vpcCidr"
  pubSubIds     = module.main_vpc.public_sub_ids
  pvtAppSubAIds = module.main_vpc.pri_app_sub_a_ids
  pvtAppSubCIds = module.main_vpc.pri_app_sub_c_ids
  pvtDBSubAIds  = module.main_vpc.pri_db_sub_a_ids
  pvtDBSubCIds  = module.main_vpc.pri_db_sub_c_ids
  kubeControllerSGIds = module.sg.kube_controller_sg_id
  kubeWorkerSGIds     = module.sg.kube_worker_sg_id
  albSGIds            = module.sg.alb_sg_id
  bastionSGIds        = module.sg.bastion_sg_id
  dbMysqlSGIds        = module.sg.db_mysql_sg_id
  bastionAmi    = "$bAmi"
  kubeCtlAmi    = "$srvAmi"
  kubeCtlType   = "$srvType"
  kubeCtlVolume = $srvVolume
  kubeCtlCount  = $srvCount
  kubeNodAmi    = "$nodAmi"
  kubeNodType   = "$nodType"
  kubeNodVolume = $nodVolume
  kubeNodCount  = $nodCount
  keyName       = "$keyName"
}

EOF

설정 파일 출력
echo "==========현재 설정=========="
echo "가용영역1: ${azs1}"
echo "가용영역2: ${azs2}"
echo "프로젝트명: ${prjt}"
echo "VPC_대역: ${vpcCidr}"
echo "SSH_OPEN_IP: ${myIp}"
echo "BASTION_AMI: ${bAmi}"
echo "KUBE_CTL_AMI: ${srvAmi}"
echo "KUBE_CTL_Type: ${srvType}"
echo "KUBE_CTL_Storage: ${srvVolume}"
echo "KUBE_CTL_COUNT: ${srvCount}"
echo "KUBE_WORKER_AMI: ${nodAmi}"
echo "KUBE_WORKER_Type: ${nodType}"
echo "KUBE_WORKER_Storage: ${nodVolume}"
echo "KUBE_WORKER_COUNT: ${nodCount}"
echo "==========================="

#내용 확인 선택문
read -p "위 내용이 맞습니까?[y/n]: " check
if [ $check == "y" ];then
	echo "환경설정이 완료되었습니다."
	break	#루프문 탈출
else
  echo "환경설정을 초기화합니다."
fi

#루프문 끝
done
