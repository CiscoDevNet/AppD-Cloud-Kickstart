#!/bin/sh -eux
# install amazon corretto 8 openjdk by amazon.

# install amazon corretto 8. -----------------------------------------------------------------------
jdkhome="jdk180"
jdkbuild="8.232.09.1"
#jdkchecksum="3511152bd52c867f8b550d7c8d7764aa"
jdkfolder="amazon-corretto-${jdkbuild}-linux-x64"
jdkbinary="amazon-corretto-${jdkbuild}-linux-x64.tar.gz"
#jdkbinary="amazon-corretto-${jdkbuild:0:1}-x64-linux-jdk.tar.gz"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download corretto 8 binary from aws.
wget --no-verbose https://corretto.aws/downloads/resources/${jdkbuild}/${jdkbinary}
#wget --no-verbose https://corretto.aws/downloads/latest/${jdkbinary}

# extract corretto 8 binary and create softlink to 'jdk180'.
rm -f ${jdkhome}
tar -zxvf ${jdkbinary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdkfolder}
ln -s ${jdkfolder} ${jdkhome}
rm -f ${jdkbinary}

# set corretto 8 home environment variables.
JAVA_HOME=/usr/local/java/${jdkhome}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java -version
