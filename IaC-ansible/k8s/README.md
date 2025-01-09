- `k8s_docker_install.yaml` : Docker 런타임<br>
- `k8s_containerd_install.yaml` :  containerd 런타임<br>
- `k8s_configure_node.yaml` :  Kubernetes 노드 구성<br>
- `k8s_join_control.yaml` : 컨트롤 플레인 노드를 Kubernetes 클러스터에 조인<br>
- `k8s_join_worker.yaml` : 워커 노드를 Kubernetes 클러스터에 조인<br>
- `kube_copy_admin_conf.yaml` : Kubernetes 클러스터 관리를 위한 설정 파일을 사용자 환경에 복사<br>

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