#!/bin/sh -eux
# install java se 15 development kit by oracle.

# install java se 15 development kit. --------------------------------------------------------------
jdk_home="jdk15"
jdk_build="15.0.1%2B9"
jdk_hash="51f4f36ad4ef43e39d0dfdbaf6549e32"
jdk_folder="jdk-15"
jdk_binary="${jdk_folder}_linux-x64_bin.tar.gz"
jdk_sha256="445a1c5c335b53b030f68aca58493ddedd49f4b53085618bc1ae7aba68156606"

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
