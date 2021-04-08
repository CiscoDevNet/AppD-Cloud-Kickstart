#!/bin/sh -eux
# install docker compose on centos 7.x.

# install docker-compose utility. ------------------------------------------------------------------
dc_binary="docker-compose-$(uname -s)-$(uname -m)"
dc_exe="docker-compose"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# set current date for temporary filename.
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# retrieve version number of latest release.
curl --silent --dump-header curl-docker-compose.${curdate}.out https://github.com/docker/compose/releases/latest --output /dev/null
dc_release=$(awk '{ sub("\r$", ""); print }' curl-docker-compose.${curdate}.out | awk '/Location/ {print $2}' | awk -F "/" '{print $8}')
dc_release="1.29.0"
dc_sha256="65bf4d3dcc5ea5dcd4644434271879a2b47e98bcfa6ca958523079c17e5adb5c"
rm -f curl-docker-compose.${curdate}.out

# download docker compose utility from github.com.
rm -f ${dc_binary}
curl --silent --location "https://github.com/docker/compose/releases/download/${dc_release}/${dc_binary}" --output ${dc_binary}

# verify the downloaded binary.
echo "${dc_sha256} ${dc_binary}" | sha256sum --check
# docker-compose-$(uname -s)-$(uname -m): OK

# rename the binary and make executable.
mv -f ${dc_binary} ${dc_exe}
chmod 755 ${dc_exe}

# set docker-compose home environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
docker-compose --version
