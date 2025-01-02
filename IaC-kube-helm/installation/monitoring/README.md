# 노드익스포터 - 프로메테우스 - 그라파나 모니터링 <br>

헬름으로 설치했어요 ! <br>
 <br>
kubectl create namespace monitoring <br>
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 <br>
chmod 700 get_helm.sh <br>
./get_helm.sh <br>
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts <br>
helm repo update <br>
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring <br>
kubectl --namespace monitoring get pods -l "release=prometheus" <br>
kubectl get pods -n monitoring <br>
kubectl patch svc prometheus-grafana -n monitoring --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' <br>
kubectl patch svc prometheus-grafana -n monitoring -p '{"spec": {"ports": [{"name": "monitoring", "nodePort": 30081, "port": 3000,  "protocol": "TCP", "targetPort": 3000}]}}' <br>

