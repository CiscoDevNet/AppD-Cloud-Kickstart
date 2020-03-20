#!/bin/sh -eux
# install java se 13 development kit by oracle.

# install java se 13 development kit. --------------------------------------------------------------
jdk_home="jdk13"
jdk_build="13.0.2+8"
jdk_hash="d4173c853231432d94f001e99d882ca7"
jdk_folder="jdk-13.0.2"
jdk_binary="${jdk_folder}_linux-x64_bin.tar.gz"
jdk_sha256="e2214a723d611b4a781641061a24ca6024f2c57dbd9f75ca9d857cad87d9475f"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 13 binary from oracle otn.
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/${jdk_build}/${jdk_hash}/${jdk_binary}

# verify the downloaded binary.
echo "${jdk_sha256} ${jdk_binary}" | sha256sum --check
# ${jdk_folder}_linux-x64_bin.tar.gz: OK

# extract jdk 13 binary and create softlink to 'jdk13'.
rm -f ${jdk_home}
tar -zxvf ${jdk_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdk_folder}
ln -s ${jdk_folder} ${jdk_home}
rm -f ${jdk_binary}

# set jdk 13 home environment variables.
JAVA_HOME=/usr/local/java/${jdk_home}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java -version
