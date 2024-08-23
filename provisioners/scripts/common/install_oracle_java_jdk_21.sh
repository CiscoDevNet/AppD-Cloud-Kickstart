#!/bin/bash -eux
# install java se 21 development kit by oracle.

# install java se 21 development kit. --------------------------------------------------------------
jdk_home="jdk21"
jdk_build="21.0.4"
jdk_folder="jdk-${jdk_build}"
jdk_binary="${jdk_folder}_linux-x64_bin.tar.gz"
jdk_sha256="dc0d14d5cf1b44e02832a7e85d0d5eb1f4623dc389a2b7fb3d21089b84fc7eb1"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 21 binary from oracle otn.
wget --no-verbose https://download.oracle.com/java/${jdk_build:0:2}/archive/${jdk_binary}

# verify the downloaded binary.
echo "${jdk_sha256} ${jdk_binary}" | sha256sum --check
# ${jdk_folder}_linux-x64_bin.tar.gz: OK

# extract jdk 21 binary and create softlink to 'jdk21'.
rm -f ${jdk_home}
rm -rf ${jdk_folder}
tar -zxvf ${jdk_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdk_folder}
ln -s ${jdk_folder} ${jdk_home}
rm -f ${jdk_binary}

# set jdk 21 home environment variables.
JAVA_HOME=/usr/local/java/${jdk_home}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java --version
