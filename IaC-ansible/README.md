
## IaC-Ansible 설명
Ansible을 사용하여 인프라를 코드로 관리(IaC, Infrastructure as Code)하기 위한 플레이북 및 설정 파일이다. 여러 디렉터리로 구성되어 있으며, 각 디렉터리는 특정 도구와 환경 설정을 자동화하는 데 사용된다. Ansible 서버는 Terraform의 terraform output -json 명령어를 사용해 인프라 정보를 JSON 파일로 저장한 뒤, Bash Shell Script를 활용하여 자동으로 구성되었다.

### 프로젝트 디렉터리 및 파일 설명
### argocd
- `argocd_cmd_params-cm.yaml` : Argo CD 서버 설정을 위한 ConfigMap 파일
- `argocd_kustomization.yaml` : Kubernetes 클러스터에 Argo CD를 설치하는 Kustomization 파일
- `argocd_server_ingress.yaml` : ALB DNS를 사용하는 Argo CD 서버 접근을 위한 Ingress 설정 파일
<br>
### db
- `mysql_community_server_install.yaml` : EL8 계열 시스템(e.g., CentOS 8, Rocky Linux 8, AlmaLinux 8)에 MySQL Community Server를 설치하는 Ansible Playbook

- `mysql.primary.cfg.j2` : MySQL Master 서버 설정을 위한 Jinja2 템플릿 파일

- `mysql.secondary.cfg.j2` : MySQL Slave 서버 설정을 위한 Jinja2 템플릿 파일
<br>
### docker

- `docker_AL2_install.yaml` : Amazon Linux 2 인스턴스에 Docker를 설치하는 Ansible Playbook

- `docker_centos7_install.yaml` : CentOS 7 인스턴스에 Docker를 설치하는 Ansible Playbook

- `docker_ubuntu_install.yaml` : Ubuntu 인스턴스에 Docker를 설치하는 Ansible Playbook

- `docker_mysql_run.yaml` : MySQL 컨테이너를 실행하고 설정하는 Ansible Playbook
<br>
### haproxy

- `k8s_haproxy_install.yaml` : HAProxy를 설치하고 설정하는 Ansible Playbook

- `haproxy_cfg.j2` : HAProxy 설정을 위한 Jinja2 템플릿 파일
<br>
### java

- `java17_AL2_install.yaml` : Amazon Linux 2 인스턴스에 Java 17을 설치하는 Ansible Playbook

- `java17_centos7_install.yaml` : CentOS 7/RHEL 인스턴스에 Java 17을 설치하는 Ansible Playbook

- `java17_ubuntu_install.yaml` : Ubuntu 인스턴스에 Java 17을 설치하는 Ansible Playbook
<br>
### jenkins

- `jenkins_centos_secure_install.yaml` : CentOS 7/RHEL에 SSL 인증서를 사용하여 Jenkins를 설치하는 Ansible Playbook

- `jenkins_centos_install.yaml` : CentOS 7/RHEL에 Jenkins를 설치하는 Ansible Playbook

- `jenkins_ubuntu_install.yaml` : Ubuntu에 Jenkins를 설치하는 Ansible Playbook
<br>
### k8s

- `k8s_docker_install.yaml` : Kubernetes 클러스터에서 Docker 런타임을 설치하는 Ansible Playbook

- `k8s_containerd_install.yaml` : containerd 런타임을 설치하는 Ansible Playbook

- `k8s_configure_node.yaml` : Kubernetes 노드를 구성하는 Ansible Playbook

- `k8s_join_control.yaml` : 컨트롤 플레인 노드를 Kubernetes 클러스터에 조인하는 Ansible Playbook

- `k8s_join_worker.yaml` : 워커 노드를 Kubernetes 클러스터에 조인하는 Ansible Playbook

- `k8s_copy_admin_conf.yaml` : Kubernetes 클러스터 관리를 위한 설정 파일을 사용자 환경에 복사하는 Ansible Playbook

- `k8s_helm_metrics_server.yaml` : Kubernetes Metrics Server를 배포하는 Ansible Playbook
<br>
### utils

- `conf_backup.yaml` : 설정 파일을 백업하는 Ansible Playbook

- `copy_log.yaml` : 설치 로그를 백업하는 Ansible Playbook

- `gen_hosts.yaml` : 네트워크 설정을 관리하고 호스트 이름 일관성을 유지하는 Ansible Playbook

- `installed_package.yaml` : 시스템의 상태를 파악하는 Ansible Playbook

- `key_scan.yaml` : SSH 연결을 자동화하는 Ansible Playbook
<br>
### 사용 방법

1. Ansible 설치 및 환경 구성 : Ansible을 설치하고, 인벤토리 파일 준비

2. 플레이북 실행 : 각 디렉터리 내 *.yaml 파일을 실행하여 원하는 인프라 자동화

3. 템플릿 파일 : *.j2 파일은 Ansible의 Jinja2 템플릿 엔진을 사용하여 설정 파일 생성
```
ansible-playbook -i inventory argocd/argocd_kustomization.yaml
```
