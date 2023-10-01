1. Clone repo https://github.com/kubernetes-csi/csi-driver-host-path.git
2. [Deploy using instructions](repo/csi-driver-host-path/docs/deploy-1.17-and-later.md)

### Star Task
Get one worker node from yc k8s cluster
Add virtual disk
apt install tgt
configure iscsi target on all nodes
iqn.2003-01.org.linux-iscsi.cl10cqr0kj529bc3113l-efyg.x8664:sn.f63637c72ca4
user - iscsiuser
password - iscsipassword
clone repo https://github.com/kubernetes-csi/csi-driver-iscsi
install driver using [instructions](repo/csi-driver-iscsi/docs/install-csi-driver-master.md)
Edit example manifests and apply them at [path](repo/csi-driver-iscsi/examples)
make sure nginx pod is Running with no errors
