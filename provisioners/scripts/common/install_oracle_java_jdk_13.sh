#!/bin/sh -eux
# install java se 13 development kit by oracle.

# install java se 13 development kit. --------------------------------------------------------------
jdkhome="jdk13"
jdkbuild="13.0.1+9"
jdkhash="cec27d702aa74d5a8630c65ae61e4305"
jdkfolder="jdk-13.0.1"
jdkbinary="${jdkfolder}_linux-x64_bin.tar.gz"

# create java home parent folder.
mkdir -p /usr/local/java
cd /usr/local/java

# download jdk 13 binary from oracle otn.
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/${jdkbuild}/${jdkhash}/${jdkbinary}

# extract jdk 13 binary and create softlink to 'jdk13'.
rm -f ${jdkhome}
tar -zxvf ${jdkbinary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${jdkfolder}
ln -s ${jdkfolder} ${jdkhome}
rm -f ${jdkbinary}

# set jdk 13 home environment variables.
JAVA_HOME=/usr/local/java/${jdkhome}
export JAVA_HOME
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
java -version
