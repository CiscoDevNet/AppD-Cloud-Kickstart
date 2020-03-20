#!/bin/sh -eux
# install java se 14 development kit by oracle.

# install java se 14 development kit. --------------------------------------------------------------
jdk_home="jdk14"
jdk_build="14+36"
jdk_hash="076bab302c7b4508975440c56f6cc26a"
jdk_folder="jdk-14"
jdk_binary="${jdk_folder}_linux-x64_bin.tar.gz"
jdk_sha256="4639bbaecc9cc606f1a4b99fda1efcaefcbf57a7025b3828b095093a6c866afd"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 14 binary from oracle otn.
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/${jdk_build}/${jdk_hash}/${jdk_binary}

# verify the downloaded binary.
echo "${jdk_sha256} ${jdk_binary}" | sha256sum --check
# ${jdk_folder}_linux-x64_bin.tar.gz: OK

# extract jdk 14 binary and create softlink to 'jdk14'.
rm -f ${jdk_home}
tar -zxvf ${jdk_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdk_folder}
ln -s ${jdk_folder} ${jdk_home}
rm -f ${jdk_binary}

# set jdk 14 home environment variables.
JAVA_HOME=/usr/local/java/${jdk_home}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java -version
