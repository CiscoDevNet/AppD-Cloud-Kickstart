#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install the Docker Engine on Ubuntu Linux.
#
# Docker is an open platform for developing, shipping, and running applications. Docker enables you
# to separate your applications from your infrastructure so you can deliver software quickly. With
# Docker, you can manage your infrastructure in the same ways you manage your applications. By
# taking advantage of Docker’s methodologies for shipping, testing, and deploying code quickly, you
# can significantly reduce the delay between writing code and running it in production.
#
# For more details, please visit:
#   https://docs.docker.com/get-started/overview/
#   https://docs.docker.com/engine/install/ubuntu/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# update the apt repository package indexes. -------------------------------------------------------
apt-get update
dpkg --configure -a

# install tools needed to install docker. ----------------------------------------------------------
apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# add the docker repository. -----------------------------------------------------------------------
# import the gpg key.
# NOTE: when adding the repository that is provided by docker, because of ubuntu security
#       restrictions, you cannot just add a repository. you also need to include the gpg key and
#       import it as a trusted key on the local operating system.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88

# add the docker repository.
add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# install docker on ubuntu. ------------------------------------------------------------------------
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io

# verify the docker installation. ------------------------------------------------------------------
# start the docker service and configure it to start at boot time.
#systemctl start docker
#systemctl enable docker

# check that the docker service is running.
#systemctl status docker

# display configuration info and verify version.
#docker info
#docker version
docker --version
