systemctl restart kubelet
sudo kubeadm init --ignore-preflight-errors=all --cri-socket /var/run/crio/crio.sock
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl taint nodes --all node-role.kubernetes.io/master-