### First task. deploy k8s 1.23 using kubeadm and upgrade it to 1.24
Console output
otusadmin@master-01:~$ kubectl get nodes -o wide
NAME        STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master-01   Ready    control-plane   57m   v1.24.0   10.128.0.27   <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.6.24
worker-01   Ready    <none>          38m   v1.24.0   10.128.0.12   <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.6.24
worker-02   Ready    <none>          38m   v1.24.0   10.128.0.16   <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.6.24
worker-03   Ready    <none>          38m   v1.24.0   10.128.0.33   <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.6.24

### Star task. Deploy k8s cluster with 3 masters and 2 workers using kubespray
Console output
otusadmin@node1:~$ kubectl get nodes -o wide
NAME    STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
node1   Ready    control-plane   26m   v1.28.2   10.128.0.26   <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.7.6
node2   Ready    control-plane   26m   v1.28.2   10.128.0.17   <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.7.6
node3   Ready    control-plane   25m   v1.28.2   10.128.0.8    <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.7.6
node4   Ready    <none>          25m   v1.28.2   10.128.0.4    <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.7.6
node5   Ready    <none>          25m   v1.28.2   10.128.0.22   <none>        Ubuntu 20.04.6 LTS   5.4.0-163-generic   containerd://1.7.6