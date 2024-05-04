#!/bin/bash -eux
# install java se 22 development kit by oracle.

# install java se 22 development kit. --------------------------------------------------------------
jdk_home="jdk22"
jdk_build="22.0.1"
jdk_folder="jdk-${jdk_build}"
jdk_binary="${jdk_folder}_linux-x64_bin.tar.gz"
jdk_sha256="bb1a6995ae63a04456b1f08fae70a71be59fc1e350c2748a252e87b07bc1c36e"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 22 binary from oracle otn.
wget --no-verbose https://download.oracle.com/java/${jdk_build:0:2}/archive/${jdk_binary}

# verify the downloaded binary.
echo "${jdk_sha256} ${jdk_binary}" | sha256sum --check
# ${jdk_folder}_linux-x64_bin.tar.gz: OK

# extract jdk 22 binary and create softlink to 'jdk22'.
rm -f ${jdk_home}
rm -rf ${jdk_folder}
tar -zxvf ${jdk_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdk_folder}
ln -s ${jdk_folder} ${jdk_home}
rm -f ${jdk_binary}

# set jdk 22 home environment variables.
JAVA_HOME=/usr/local/java/${jdk_home}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java --version
