#!/bin/sh -eux
# install java se 20 development kit by oracle.

# install java se 20 development kit. --------------------------------------------------------------
jdk_home="jdk20"
jdk_build="20.0.1"
jdk_folder="jdk-${jdk_build}"
jdk_binary="${jdk_folder}_linux-x64_bin.tar.gz"
jdk_sha256="bb118683feb4d66476198c8176a9845a9125bf5b303089b56b4b59ff9a544ccf"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 20 binary from oracle otn.
wget --no-verbose https://download.oracle.com/java/${jdk_build:0:2}/archive/${jdk_binary}

# verify the downloaded binary.
echo "${jdk_sha256} ${jdk_binary}" | sha256sum --check
# ${jdk_folder}_linux-x64_bin.tar.gz: OK

# extract jdk 20 binary and create softlink to 'jdk20'.
rm -f ${jdk_home}
rm -rf ${jdk_folder}
tar -zxvf ${jdk_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdk_folder}
ln -s ${jdk_folder} ${jdk_home}
rm -f ${jdk_binary}

# set jdk 20 home environment variables.
JAVA_HOME=/usr/local/java/${jdk_home}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java --version
