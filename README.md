# aablago4_platform
aablago4 Platform repository

Lecture 02 - Kubernetes intro.
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

Lecture 03 - Kubernetes controllers
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