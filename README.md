# aablago4_platform
aablago4 Platform repository

Homework #1 - Kubernetes intro.
Base Tasks:
1. Build custom docker image with customizations.
   aablago4/nginx_custom:1.0
2. Create manifest with custom docker image
    web-pod.yaml

Advanced Tasks:
1. Build custom docker image from https://github.com/GoogleCloudPlatform/microservices-demo frontend
   aablago4/hipstershop:1.0
2. Make yaml file to launch frontend
   frontend-pod.yaml
3. Figure why things does not works
    - manually run pod with custom container image.
    - get error about environment variables
    - add some sections in yaml file save it with new name frontend-pod-healthy.yaml
    - push frontend-pod-healthy.yaml
    - success

Homework #2 - Kubernetes controllers
1. Create kind cluster with 6 nodes (3 - master, 3 - worker)
2. Create replicaset with custom frontend application container image from dockerhub.
3. Create two versions of custom frontend application container image.
4. Create two versions of custom payment application container image.
5. Create deployment and make some operations with update strategy.
6. *Create blue-green update deployment paymentservice-deployment-bg.yaml with maxSurge and maxUnavailable sections.
7. *Create reverse update paymentservice-deployment-reverse.yaml with maxSurge and maxUnavailable sections.
8. Make frontend-deployment.yaml with readiness probe and do some iterations.
9. *Make nodeexporter-daemonset.yaml with prometeus node exporter container image prom/node-exporter
10. *Make some successfull tests with port forwarding
11. **Add tolerations sections to yaml file to create containers on worker and master nodes.

Homework #3 - Kubernetes Networks
1. Start minikube
2. Create web-pod with readinessprobe
3. Add livenessProbe to web-pod
4. Create deployment web-deploy
5. Add maxSurge & maxUnavailable specs
6. Create ClusterIP service web-svc-cip
7. Make some extra configs for IPVS (strictARP)
8. Create deployment with metalLB
9. Make some configs metallb-config.yaml *custom*
10. Create LoadBalancer service web-svc-lb.yaml
11. Add route 172.17.255.0 with 192.168.49.2 gateway for host VM
12. *Star task* DNS over metallb -> ./coredns/dns-svc-lb.yaml
13. Create ingress from scratch.
14. Create nginx-controller service nginx-lb.yaml
15. Create IP-less service for advanced load balancing web-svc-headless.yaml
16. Create ingress rules web-ingress.yaml. make some additional config.
17. curl http://LB_IP/web/index.html
18. *Star task* Ingress for dashboard.
    1. Deploy cert-manager from scratch
    2. Deploy kubernetes dashboard from scratch
    3. Create ingress rule for dashboard ./dashboard/dash-ingress.yaml
    4. curl http://LB_IP/dashboard
19. *Star task* Canary deployment for ingress
    1. copy web-deploy.yaml, web-svc-headless,web-ingress to ./canary/deployment.yaml
    2. Edit names\labels in deployment.yaml
    3. Add canary notations to ingress rule. canary: true, weigth: 50
    4. seq 200 | xargs -Iz curl -s http://ingress.local/web/index.html | grep HOSTNAME
    5. 50% of requests routes to canary pods

Homework #4 - Kubernetes Volumes
1. Create kind cluster
2. Create and apply minio-statefulset.yaml
3. Create and apply minio-headless-service.yaml
4. List resources
5. Remove stateful set
6. Create and apply stateful set manifest using secrets
   1. Create and apply minio-secrets.yaml (two secrets)
   2. Create and apply minio-statefulset-secrets.yaml
   3. Check stateful set
7. Delete kind cluster
8. Start minikube
9. Create persistent volume on minikube node my-pv.yaml
10. Create persistent volume claim my-pvc.yaml
11. Take our old web-svc and apply persistent volume mounting my-pod.yaml
12. Start my-pod
13. Make some checks
    1. Enter shell in working pod
    2. Make some data in /app/data create two files
    3. Remove pod
    4. Create new pod with same yaml file
    5. Enter shell in working pod
    6. List files in /app/data

Homework #5 - Kubernetes Security

1. Task01
   1. Create service account bob, create cluster role binding for bob
   2. Create service account dave, no cluster role bindings
2. Task02
   1. Create namespace
   2. Create service account carol in new namespace
   3. Create cluster role with get, list and watch permissions on Pods
   4. Create cluster role binding with new service account and new role
3. Task03
   1. Create namespace
   2. Create new service accounts
   3. Create cluster role bindings for new service accounts