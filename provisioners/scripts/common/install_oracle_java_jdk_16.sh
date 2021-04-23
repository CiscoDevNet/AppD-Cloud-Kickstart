#!/bin/sh -eux
# install java se 16 development kit by oracle.

# install java se 16 development kit. --------------------------------------------------------------
jdk_home="jdk16"
jdk_build="16.0.1+9"
jdk_hash="7147401fd7354114ac51ef3e1328291f"
jdk_folder="jdk-${jdk_build:0:-2}"
jdk_binary="${jdk_folder}_linux-x64_bin.tar.gz"
jdk_sha256="caa0bfc0e9ee52f45c8f8ca803a23f132ef551297c6b9331b091110c5740a9bf"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 16 binary from oracle otn.
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/${jdk_build}/${jdk_hash}/${jdk_binary}

# verify the downloaded binary.
echo "${jdk_sha256} ${jdk_binary}" | sha256sum --check
# ${jdk_folder}_linux-x64_bin.tar.gz: OK

# extract jdk 16 binary and create softlink to 'jdk16'.
rm -f ${jdk_home}
tar -zxvf ${jdk_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdk_folder}
ln -s ${jdk_folder} ${jdk_home}
rm -f ${jdk_binary}

# set jdk 16 home environment variables.
JAVA_HOME=/usr/local/java/${jdk_home}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java --version
