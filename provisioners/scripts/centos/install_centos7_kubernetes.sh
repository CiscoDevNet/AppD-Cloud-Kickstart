#!/bin/sh -eux
# install kubernetes on centos 7.x.

# configure docker service for use by kubernetes. --------------------------------------------------
# create '/etc/docker' directory.
mkdir -p /etc/docker

# setup docker daemon for kubernetes.
cat <<EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# create docker 'systemd' service directory.
mkdir -p /etc/systemd/system/docker.service.d

# restart docker.
systemctl daemon-reload
systemctl restart docker

# configure kubernetes system prerequisites. -------------------------------------------------------
# configure ip tables for kubernetes.
cat <<EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# explicitly load 'br_netfilter' module and reload kernel parameter configuration files.
modprobe br_netfilter
sysctl --system

# turn off swap for kubernetes installation.
swapoff -a
sed -e '/swap/s/^/#/g' -i /etc/fstab

# allow kubernetes service ports on the master node:
#   Port        Protocol    Purpose
#   6443        TCP         Kubernetes API server
#   2379-2380   TCP         etcd server client API
#   10250       TCP         Kubelet API
#   10251       TCP         kube-scheduler
#   10252       TCP         kube-controller-manager
#firewall-cmd --permanent --add-port={6443,2379,2380,10250,10251,10252}/tcp
#firewall-cmd --reload

# allow kubernetes service ports on the worker node:
#   Port        Protocol    Purpose
#   10250       TCP         Kubelet API
#   30000-32767 TCP         NodePort Services
#firewall-cmd --permanent --add-port={10250,30000-32767}/tcp
#firewall-cmd --reload

# set selinux in permissive mode (effectively disabling it).
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# install the kubernetes repository. ---------------------------------------------------------------
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

# build yum cache for kubernetes repository.
yum -y makecache fast

# install kubernetes packages. ---------------------------------------------------------------------
yum -y install kubelet kubeadm kubectl --disableexcludes=kubernetes

# start the kubernetes service and configure it to start at boot time.
systemctl enable --now kubelet
#systemctl enable kubelet
#systemctl start kubelet

# add the kubernetes bash completion script.
kubectl completion bash > /etc/bash_completion.d/kubectl

# verify installation.
kubelet --version
kubeadm version
kubectl version --short --client
