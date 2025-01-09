- `argocd_cmd_params-cm.yaml` : Argo CD 서버 설정 ConfigMap
- `argocd_kustomization.yaml` : Kubernetes 클러스터에 ArgoCd 설치(Kustomization)
- `argocd_server_ingress.yaml` : Argo CD 서버 접근 Ingress 설정 (ALB DNS 사용)

#### .github/workflows 백업 파일(GitHub Actions)
- `argocd_sync_application.yaml` : Argo CD 애플리케이션 정의 (manifest)
- `argocd_pod_autoscaler.yaml` : Kubernetes Horizontal Pod Autoscaler(HPA) 정의 (manifest)
- `argocd_rollout_bluegreen.yaml` : Argo Rollouts로 Blue/Green 배포 구현 (manifest)
- `argocd_rollout_canary.yaml` : Argo Rollouts로 Canary 배포 구현 (manifest)
- `argocd_build_push_yaml` : GitHub Actions workflow 파일 (manifest)