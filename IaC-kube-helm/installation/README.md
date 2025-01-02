# 네트워크 플러그인 - 캘리코 <br>
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml <br>
<br>

# 메트릭 서버 배포에 대한 설정사항 <br>
line 140 >  - --kubelet-insecure-tls <br>
클러스터 kubelet에 대한 tls 인증에 대한 부분이 없어서 tls 보안설정을 내렸습니다