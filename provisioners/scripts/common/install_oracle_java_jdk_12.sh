#!/bin/sh -eux
# install java se 12 development kit by oracle.

# install java se 12 development kit. --------------------------------------------------------------
jdkhome="jdk12"
jdkbuild="12.0.2+10"
jdkhash="e482c34c86bd4bf8b56c0b35558996b9"
jdkfolder="jdk-12.0.2"
jdkbinary="${jdkfolder}_linux-x64_bin.tar.gz"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 12 binary from oracle otn.
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/${jdkbuild}/${jdkhash}/${jdkbinary}

# extract jdk 12 binary and create softlink to 'jdk12'.
rm -f ${jdkhome}
tar -zxvf ${jdkbinary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdkfolder}
ln -s ${jdkfolder} ${jdkhome}
rm -f ${jdkbinary}

# set jdk 12 home environment variables.
JAVA_HOME=/usr/local/java/${jdkhome}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java -version
