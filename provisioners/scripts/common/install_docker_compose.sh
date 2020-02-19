#!/bin/sh -eux
# install docker compose on centos 7.x.

# install docker-compose utility. ----------------------------------------------
dcbin="docker-compose"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# retrieve version number of latest release.
curl --silent --dump-header curl-docker-compose.${curdate}.out https://github.com/docker/compose/releases/latest --output /dev/null
dcrelease=$(awk '{ sub("\r$", ""); print }' curl-docker-compose.${curdate}.out | awk '/Location/ {print $2}' | awk -F "/" '{print $8}')
dcrelease="1.25.4"
rm -f curl-docker-compose.${curdate}.out

# download docker compose utility from github.com.
rm -f ${dcbin}
curl --silent --location "https://github.com/docker/compose/releases/download/${dcrelease}/docker-compose-$(uname -s)-$(uname -m)" --output ${dcbin}
chmod 755 ${dcbin}

# set docker-compose home environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
docker-compose --version
