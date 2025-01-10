# AWS 환경에 웹 서비스 구축 및 배포

## \#EPISODE I.인프라 자동화 및 표준화

## 프로젝트 설명
본 프로젝트는 클라우드 네이티브 환경에서 웹 서비스 "GymFit"을 구축하고 자동화된 배포 시스템을 구현하는 것을 목표로 한다. GymFit은 피트니스 센터, 트레이너, 회원을 연결하는 통합 서비스를 제공한다. 개발팀과 인프라팀으로 구성된 협업 프로젝트이며, GitOps 기반 CI/CD 파이프라인을 통해 무중단 배포를 실현하였다.

<br>

## AWS Architecture
![aws_architecture](https://github.com/user-attachments/assets/fd338455-afc3-429f-9dc5-515f6b06f639)

<br>

## 전반적인 흐름
- Terraform을 사용하여 AWS 인프라를 자동으로 구축
- Ansible을 사용하여 Kubernetes 클러스터를 구성하고 필요한 소프트웨어 설치

<br>

## 1단계 : Terraform을 사용한 인프라 구축

- `InfraAutomation.sh` 스크립트를 실행하여 AWS 리전 및 가용 영역, VPC CIDR 대역 등 기본 정보 입력
- 스크립트는 Terraform을 사용하여 다음과 같은 AWS 리소스를 프로비저닝
1. VPC, Public Subnet, Private Subnet(App, DB)
2. Internet Gateway, NAT Gateway, Route Table
3. Security Group(Bastion Host, ALB, Kubernetes Controller, Kubernetes Worker, DB)
4. EC2 Instance(Bastion Host, Kubernetes Controller, Kubernetes Worker, DB)
5. Load Balancer(Public ALB, Private ALB)
6. Target Group(외부 서비스, Argo CD, Monitoring, Kubernetes ALB)
7. Listene(Argo CD, Monitoring, Kubernetes API)
8. SSH Key Pair
- modules 디렉토리에 있는 Terraform 모듈을 사용하여 리소스를 모듈화하고 재사용성을 높임
- `terraform output -json` 명령어를 사용하여 생성된 리소스 정보를 output.json 파일로 저장

<br>

## 2단계 : Ansible을 사용한 Kubernetes 클러스터 설정
- `BastionSet.sh` 스크립트를 실행하여 Bastion Host를 설정하고 Ansible을 통해 Kubernetes 클러스터 구성
- `output.json` 파일에서 Kubernetes Controller 및 Worker Node의 IP 정보를 추출하여 `user.info`(Ansible 인벤토리) 파일에 추가
- `keyscan.info` 파일에는 SSH keyscan을 위한 Worker Node IP 목록 저장
- Bastion Host에서 Ansible 서버(Kubernetes Controller)로 접속하여 `user.info`, `keyscan.info` 파일 전송
- Ansible 서버에서 `ansible.sh` 스크립트를 실행하여 `user.info` 파일을 /etc/ansible/hosts(Ansible hosts 파일)로 복사
- `keyscan.sh` 스크립트를 실행하여 모든 Worker Node에 대한 SSH keyscan을 수행하고 `known_hosts` 파일 업데이트
- Ansible Playbook을 사용하여 Kubernetes Control Plane 및 Worker Node를 구성하고 Kubernetes 클러스터 생성
- argocd 디렉토리에 있는 Playbook을 사용하여 Argo CD를 설치하고 Ingress 설정
- db 디렉토리에 있는 Playbook을 사용하여 MySQL을 설치 및 설정

<br>

## 3단계 : Kubernetes 클러스터 접속 및 관리

- Bastion Host를 통해 Kubernetes Control Plane에 SSH로 접속
- kubectl 명령어를 사용하여 Kubernetes 클러스터 관리
- Argo CD를 사용하여 애플리케이션을 배포하고 관리

<br>

## 함께 보기
[![Naver Blog Badge](https://img.shields.io/badge/Naver%20Blog-03C75A?style=flat&logo=Naver&logoColor=white)](https://blog.naver.com/genie290/223451486457)
