- `k8s_docker_install.yaml` : Docker 런타임
- `k8s_containerd_install.yaml` :  containerd 런타임
- `k8s_configure_node.yaml` :  Kubernetes 노드 구성
- `k8s_join_control.yaml` : 컨트롤 플레인 노드를 Kubernetes 클러스터에 조인
- `k8s_join_worker.yaml` : 워커 노드를 Kubernetes 클러스터에 조인
- `k8s_copy_admin_conf.yaml` : Kubernetes 클러스터 관리를 위한 설정 파일을 사용자 환경에 복사
- `k8s_helm_metrics_server.yaml` : Kubernetes Metrics Server 배포


### Kubernetes 설치 차이점
| 항목                      | `k8s_docker_install.yaml` (Docker) | `k8s_containerd_install.yaml` (containerd) |
| ------------------------- | ----------------------------------- | ---------------------------------------- |
| **컨테이너 런타임**        | Docker (`docker-ce`)               | containerd (`containerd` + `runc`)       |
| **SELinux 설정**          | SELinux `permissive`로 설정        | 해당 설정 없음                          |
| **Swap 비활성화**         | 현재 세션 및 재부팅 후 비활성화     | 해당 설정 없음                          |
| **런타임 설치 방식**       | `yum`으로 패키지 설치              | 바이너리 수동 다운로드 및 설치          |
| **서비스 관리**           | `docker` 서비스 활성화             | `containerd` 서비스 활성화              |
| **CNI 플러그인 설치**      | 없음                              | CNI 플러그인 직접 다운로드 및 설치       |
| **커널 모듈 로딩**         | 없음                              | `overlay` 및 `br_netfilter` 직접 로딩    |
| **패키지 관리 방식**       | `yum_repository` 사용             | `yum_repository` 및 직접 바이너리 다운로드 |
| **쿠버네티스 버전**        | `v1.28`                          | `v1.28`                                 |


### Kubernetes 클러스터 모니터링 시스템 구성 가이드
- 네트워크 플러그인(Calico) 설치
```
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

- k8s_helm_metrics_server.yaml > line 140
```
 - --kubelet-insecure-tl  # 클러스터 kubelet에 대한 tls 인증에 대한 부분이 없어서 tls 보안 설정 내림
```

### Prometheus + Node Exporter + Grafana 모니터링 시스템 배포
- Monitoring 네임스페이스 생성
```
kubectl create namespace monitoring
```

- Helm 설치 및 Prometheus Stack 배포
```
# Helm 설치 스크립트 다운로드 및 실행
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Prometheus Helm Chart 저장소 추가 및 업데이트
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# kube-prometheus-stack 설치
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
```

- 설치 확인
```
kubectl --namespace monitoring get pods -l "release=prometheus"
kubectl get pods -n monitoring
```

- Grafana NodePort 설정(서비스 타입을 NodePort로 변경하여 30081 포트로 Grafana를 노출)
```
# NodePort로 변경
kubectl patch svc prometheus-grafana -n monitoring --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]'

# 포트 매핑 설정 (30081 포트 사용)
kubectl patch svc prometheus-grafana -n monitoring -p '{"spec": {"ports": [{"name": "monitoring", "nodePort": 30081, "port": 3000, "protocol": "TCP", "targetPort": 3000}]}}'

# 브라우저에서 http://<노드 IP>:30081 접속
# admin/prom-operator
```

- 모니터링 시스템 정상 동작 확인
```
kubectl get all -n monitoring
```
