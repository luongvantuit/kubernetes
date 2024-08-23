#!/bin/bash
set +x

CRI_SOCK=${CRI_SOCK:="unix:///var/run/containerd/containerd.sock"}

sudo mv /etc/containerd/config.toml /root/config.toml.bak
sudo systemctl restart containerd

echo "----config image pull----"
sudo kubeadm config images pull --cri-socket=$CRI_SOCK

API_SERVER=""

while getopts ":h:" option; do
    case $option in
    h) # Api service K8s
        API_SERVER="--apiserver-advertise-address=$(echo $OPTARG | xargs)" ;;
    esac
done

echo "----kubeadm init----"
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=$CRI_SOCK $API_SERVER

echo "----copy config file----"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown -R 1000:1000 $HOME/.kube/config # Normal with physic machine, please use command sudo chown -R $(id -u):$(id -g) $HOME/.kube/config

echo "----installing a add-on network----"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

echo "----control plane node isolation----"
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "----installing a add-on storage----"
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
sleep 10
kubectl get storageclass
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "----installing metallb---"
# actually apply the changes, returns nonzero returncode on errors only
kubectl get configmap kube-proxy -n kube-system -o yaml |
    sed -e "s/strictARP: false/strictARP: true/" |
    kubectl apply -f - -n kube-system
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/config/manifests/metallb-native-prometheus.yaml

echo "----kubeadm init done----"

echo "----logging sysinfo----"
landscape-sysinfo
