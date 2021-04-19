#!/bin/sh -eux
# install the docker engine on centos 7.x.

# install the docker prerequisites. ----------------------------------------------------------------
yum -y install yum-utils device-mapper-persistent-data lvm2

# install the docker repository. -------------------------------------------------------------------
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# enable/disable optional docker repositories.
# note: these repositories are included in the docker.repo file above but are disabled by default.
#       you can enable them alongside the stable repository.
#yum-config-manager --enable docker-ce-nightly   # optional.
#yum-config-manager --enable docker-ce-test      # optional.

#yum-config-manager --disable docker-ce-nightly  # optional.
#yum-config-manager --disable docker-ce-test     # optional.

# list and sort the versions available in your repo.
# sort results by version number, highest to lowest, and truncate the results.
#yum list docker-ce --showduplicates | sort -r

# build yum cache for docker repository.
yum -y makecache fast

# install the docker community edition engine. -----------------------------------------------------
yum -y install docker-ce docker-ce-cli containerd.io

# install a specific version by its fully qualified package name.
#yum -y install docker-ce-18.09.9 docker-ce-cli-18.09.9 containerd.io

# configure docker. --------------------------------------------------------------------------------
# enable ip forwarding if not set.
sysctlfile="/etc/sysctl.conf"
ipv4cmd="net.ipv4.ip_forward=1"
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
