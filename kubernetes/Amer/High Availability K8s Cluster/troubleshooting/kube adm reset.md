sudo kubeadm reset
sudo rm -rf /etc/kubernetes/manifests/*
sudo rm -rf /var/lib/etcd/*
sudo systemctl restart containerd
sudo netstat -tuln | grep -E '6443|10259|10257|10250|2379|2380'
sudo lsof -i :6443
sudo lsof -i :10259
sudo kubeadm init --control-plane-endpoint "192.168.2.166:6443" --upload-certs
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
  
  Firewall Rules :
Ensure port 10250 is open on the worker node:

sudo ufw allow 10250/tcp

#check
#Turn Off Swap Temporarily :
sudo swapoff -a

#Disable Swap Permanently :
sudo nano /etc/fstab
# /swap.img       none    swap    sw      0       0

#Once swap is disabled, restart the kubelet service:
sudo systemctl daemon-reload
sudo systemctl restart kubelet