<pre>
# miniproject-ansible
terraformInfra-ansibleService-repository  

# 디렉토리 설명
ci-cd - CI/CD 관련 설치 yaml파일 
db - db 설치 설정 jinja2 템플릿 및 플레이북 
docker - os 별 docker 설치 플레이북 
haproxy - haproxy - keepalived 고가용성 및 장애대응 설정 파일 
java - os 별 java 설치 플레이북 
kube - 쿠버네티스 인스톨 및 설정 파일 
utils - 유용할 수 있는 기능들 ( 설정파일 백업, log복사, hosts파일 생성, 호스트에 설치된 패키지 가져오기 ) 

# 사용된 ansible.cfg 설정
[defaults] 
inventory = /home/ec2-user/.ansible/aws_ec2.yml 
private_key_file = 개인키 위치/ 개인 키 이름 
host_key_checking = False 

[inventory] 
enable_plugins = amazon.aws.aws_ec2 
 
[privilege_escalation] 
become = true 
become_method = sudo 
become_user = root 
become_ask_pass = false 

# 사용된 ansible dynamic inventory 구성 
 
plugin: amazon.aws.aws_ec2 
regions: 
  - "ap-south-1" 
keyed_groups: 
  - key: tags 
    prefix: tag 
  - prefix: instance_type 
    key: instance_type 
  - key: placement.region 
    prefix: aws_region 
filters: 
  instance-state-name: running 
compose: 
  ansible_host: private_ip_address 

</pre>
