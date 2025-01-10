## IaC-terraform 설명
Terraform과 Ansible을 사용하여 AWS에 Kubernetes 클러스터를 구축하기 위한 환경을 구성한다.
```
├── modules
│   ├── ec2
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── user_data
│   │   │   ├── user_data_bastion_host.sh
│   │   │   ├── user_data_db_mysql.sh
│   │   │   └── user_data_kubecontroller.sh
│   │   └── variables.tf
│   ├── sg
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   └── vpc
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── amiName.data
├── BastionSet.sh
├── InfraAutomation.sh
├── main.tf
├── output.tf
└── terraform.tfvars
```

<br>

## 주요 기능
- Terraform : AWS 리소스(VPC, Subnet, Security Group, EC2 Instance, Load Balancer, Target Group, Listener 등)를 자동으로 생성하고 관리
- Ansible : Kubernetes Control Plane 및 Worker Node에 대한 설정 및 소프트웨어 설치 자동화
- Bastion Host : Kubernetes Control Plane에 안전하게 접근하기 위한 Bastion Host 제공
- Public ALB & Private ALB : 외부 트래픽과 내부 트래픽을 분리하여 보안을 강화하고, 각 서비스에 맞는 트래픽 관리 기능 제공
- Auto Scaling : Kubernetes Worker Node에 대한 Auto Scaling을 지원하여 트래픽 부하에 따라 자원을 동적으로 조정
- 다양한 AMI 지원 : Amazon Linux 2, Ubuntu 20.04, RHEL 9 등 다양한 AMI를 선택하여 인스턴스 생성
- 가용 영역 설정 : 원하는 가용 영역을 선택하여 리소스 배포
- VPC 설정 : VPC CIDR 블록을 설정하여 네트워크 환경 구성
- 보안 그룹 설정 : Bastion Host, ALB, Kubernetes 노드, DB에 대한 보안 그룹을 설정하여 네트워크 트래픽 제어
- SSH Key 관리 : SSH Key Pair를 생성하고 관리하여 인스턴스에 안전하게 접근

<br>

## 추가 정보
- `modules` 디렉토리에는 VPC, Security Group, EC2 Instance 등을 정의하는 Terraform 모듈이 포함되어 있음
- `user.info` 파일에는 Ansible 인벤토리 정보가 저장됨
- `keyscan.info` 파일에는 SSH keyscan을 위한 IP 목록이 저장됨
- `bastion.sh`는 Bastion Host에서 실행되는 쉘 스크립트
- `ansible.sh`는 Ansible 서버에서 실행되는 쉘 스크립트
- `keyscan.sh`는 SSH keyscan을 수행하는 쉘 스크립트

<br>

## 주의사항
- AWS 환경에서 작동
- 스크립트 실행 전 AWS 계정에 대한 권한 필요함
- 보안을 위해 SSH Key Pair를 안전하게 관리할 필요가 있음