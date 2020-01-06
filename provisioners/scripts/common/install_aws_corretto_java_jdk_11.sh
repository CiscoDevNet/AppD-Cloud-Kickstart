#!/bin/sh -eux
# install amazon corretto 11 openjdk by amazon.

# install amazon corretto 11. ----------------------------------------------------------------------
jdkhome="jdk11"
jdkbuild="11.0.5.10.1"
#jdkchecksum="d732b6ece7b1c8117753ba8460dfaede"
jdkfolder="amazon-corretto-${jdkbuild}-linux-x64"
jdkbinary="amazon-corretto-${jdkbuild}-linux-x64.tar.gz"
#jdkbinary="amazon-corretto-${jdkbuild:0:2}-x64-linux-jdk.tar.gz"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download corretto 11 binary from aws.
wget --no-verbose https://corretto.aws/downloads/resources/${jdkbuild}/${jdkbinary}
#wget --no-verbose https://corretto.aws/downloads/latest/${jdkbinary}

# extract corretto 11 binary and create softlink to 'jdk11'.
rm -f ${jdkhome}
tar -zxvf ${jdkbinary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdkfolder}
ln -s ${jdkfolder} ${jdkhome}
rm -f ${jdkbinary}

# set corretto 11 home environment variables.
JAVA_HOME=/usr/local/java/${jdkhome}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java -version
