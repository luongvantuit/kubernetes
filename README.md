# Kubernetes

## VMWare

### Installation

If you are using Windows or Unix, then I recommend using VMWare Workstation. Otherwise if you are using MacOS,
please use VMWare Fusion.

### Deploy virtual K8s Cluster

Run Terminal or PowerShell

```sh
cd vmware_desktop
# Deploy vagrant vmware_desktop
vagrant up
```

## VirtualBox

VirtualBox is a general-purpose full virtualizer for x86 hardware, targeted at server, desktop and embedded use.

### Installation

How to setup VirtualBox

#### Ubuntu, Debian

Run a command install package `virtualbox` with `apt-get`

```sh
sudo apt-get install virtualbox
```

#### Others OS

Download from the homepage of the VirtualBox package corresponding with the OS \
Example: MacOS(.dmg), Windows(.exe)

### Deploy virtual K8s Cluster

Run Terminal or PowerShell

```sh
cd virtualbox
# Deploy vagrant virtualbox
vagrant up
```

## Reset `iptables` & K8s

```sh
kubeadm reset -f
rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes
iptables -F && iptables -X
iptables -t nat -F && iptables -t nat -X
iptables -t raw -F && iptables -t raw -X
iptables -t mangle -F && iptables -t mangle -X
```
