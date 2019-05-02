#!/bin/sh -eux
# install the docker engine on centos 7.x.

# install the docker prerequisites. --------------------------------------------
yum -y install yum-utils
yum -y install device-mapper-persistent-data
yum -y install lvm2

# install the docker repository. -----------------------------------------------
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# enable/disable optional docker repositories.
# note: starting with docker 17.06, stable releases are also pushed to the
# edge and test repositories.
#yum-config-manager --enable docker-ce-edge      # optional.
#yum-config-manager --enable docker-ce-test      # optional.

#yum-config-manager --disable docker-ce-edge     # optional.
#yum-config-manager --disable docker-ce-test     # optional.
#yum list docker-ce --showduplicates | sort -r

# install the docker community edition engine. ---------------------------------
yum -y install docker-ce

# configure docker. ------------------------------------------------------------
# enable ip forwarding if not set.
sysctlfile="/etc/sysctl.conf"
ipv4cmd="net.ipv4.ip_forward = 1"
if [ -f "$sysctlfile" ]; then
  sysctl net.ipv4.ip_forward
  grep -qF "${ipv4cmd}" ${sysctlfile} || echo "${ipv4cmd}" >> ${sysctlfile}
  sysctl -p /etc/sysctl.conf
  sysctl net.ipv4.ip_forward
fi

# start the docker service and configure it to start at boot time.
systemctl start docker
systemctl enable docker

# check that the docker service is running.
systemctl status docker

# display configuration info and verify version.
docker info
docker version
docker --version
