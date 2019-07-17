#!/bin/sh -eux
# install amazon corretto 11 openjdk by amazon.

# install amazon corretto 11. ----------------------------------------------------------------------
jdkhome="jdk11"
jdkbuild="11.0.4.11.1"
jdkhost="d3pxv6yz143wms"
#jdkchecksum="4bbcd5e6d721fef56e46b3bfa8631c1c"
jdkfolder="amazon-corretto-${jdkbuild}-linux-x64"
jdkbinary="amazon-corretto-${jdkbuild}-linux-x64.tar.gz"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download corretto 11 binary from aws.
wget --no-verbose https://${jdkhost}.cloudfront.net/${jdkbuild}/${jdkbinary}

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
