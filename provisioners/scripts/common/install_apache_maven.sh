#!/bin/sh -eux
# install maven build tool by apache.

# install apache maven. ----------------------------------------------------------------------------
m2home="apache-maven"
mvn_release="3.9.3"
mvn_folder="${m2home}-${mvn_release}"
mvn_binary="${mvn_folder}-bin.tar.gz"
mvn_sha512="400fc5b6d000c158d5ee7937543faa06b6bda8408caa2444a9c947c21472fde0f0b64ac452b8cec8855d528c0335522ed5b6c8f77085811c7e29e1bedbb5daa2"

# create apache parent folder.
mkdir -p /usr/local/apache
cd /usr/local/apache

# download maven binary from apache.org.
wget --no-verbose http://archive.apache.org/dist/maven/maven-3/${mvn_release}/binaries/${mvn_binary}

# verify the downloaded binary.
echo "${mvn_sha512} ${mvn_binary}" | sha512sum --check
# ${mvn_folder}-bin.tar.gz: OK

# extract maven binary.
rm -f ${m2home}
tar -zxvf ${mvn_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${mvn_folder}
ln -s ${mvn_folder} ${m2home}
rm -f ${mvn_binary}

# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk180
export JAVA_HOME

# set maven home environment variables.
M2_HOME=/usr/local/apache/${m2home}
export M2_HOME
M2_REPO=$HOME/.m2
export M2_REPO
MAVEN_OPTS=-Dfile.encoding="UTF-8"
export MAVEN_OPTS
M2=$M2_HOME/bin
export M2
PATH=${M2}:${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
mvn --version
