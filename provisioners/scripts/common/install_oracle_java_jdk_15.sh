#!/bin/sh -eux
# install java se 15 development kit by oracle.

# install java se 15 development kit. --------------------------------------------------------------
jdk_home="jdk15"
jdk_build="15.0.2%2B7"
jdk_hash="0d1cfde4252546c6931946de8db48ee2"
jdk_folder="jdk-${jdk_build:0:-4}"
jdk_binary="${jdk_folder}_linux-x64_bin.tar.gz"
jdk_sha256="54b29a3756671fcb4b6116931e03e86645632ec39361bc16ad1aaa67332c7c61"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 15 binary from oracle otn.
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/${jdk_build}/${jdk_hash}/${jdk_binary}

# verify the downloaded binary.
echo "${jdk_sha256} ${jdk_binary}" | sha256sum --check
# ${jdk_folder}_linux-x64_bin.tar.gz: OK

# extract jdk 15 binary and create softlink to 'jdk15'.
rm -f ${jdk_home}
tar -zxvf ${jdk_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdk_folder}
ln -s ${jdk_folder} ${jdk_home}
rm -f ${jdk_binary}

# set jdk 15 home environment variables.
JAVA_HOME=/usr/local/java/${jdk_home}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java --version
