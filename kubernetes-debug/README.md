### Strace debug
Install sample application 
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/main/release/kubernetes-manifests.yaml
strace works at worker nodes
### netperf-operator
does not works
netperf operator logs
time="2023-10-05T12:10:54Z" level=debug msg="Trying to bind the pod netperf-server-8bfdf6a86cc8 with CR"
time="2023-10-05T12:10:54Z" level=error msg="pod with UID 8a9576c1-a4a0-48fa-9813-9b08590154f8 was not detected as server nor client pod of the CR"

### Another one iperf test
https://github.com/leannetworking/k8s-netperf
log output [here](repo/k8s-netperf/test-01.log) some tests are working fine