![code80](./image.jpeg)

- ubuntu 24.04 (lima)
- kubeadm 1.37.1
- helm 4.3.0
- cilium cni
- gitops (flux 2.9.5)
- envoy gateway
- cert-manager
- external secrets
- kyverno
- podinfo
```
make up          # vm, kubeadm, cilium, flux gitops/
make e2e         # demo (gateway)
make backup      # снимок etcd в backups/
make restore SNAPSHOT=backups/snapshot-<timestamp>.db
make upgrade VERSION=1.37.1 MINOR=v1.37
make destroy     # del vm k8s-*
```