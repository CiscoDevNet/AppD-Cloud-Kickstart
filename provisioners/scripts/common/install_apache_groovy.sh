#!/bin/sh -eux
# install groovy sdk bundle by apache.

# install apache groovy. ---------------------------------------------------------------------------
groovyhome="groovy"
groovyrelease="3.0.2"
groovyfolder="${groovyhome}-${groovyrelease}"
groovysdk="apache-groovy-sdk-${groovyrelease}.zip"
#groovybinary="apache-groovy-binary-${groovyrelease}.zip"
#groovydocs="apache-groovy-docs-${groovyrelease}.zip"

# create apache parent folder.
mkdir -p /usr/local/apache
cd /usr/local/apache

# download groovy sdk bundle from apache.org.
wget --no-verbose https://dl.bintray.com/groovy/maven/${groovysdk}

# extract groovy sdk binary.
rm -f ${groovyhome}
unzip ${groovysdk}
chown -R root:root ./${groovyfolder}
ln -s ${groovyfolder} ${groovyhome}
rm -f ${groovysdk}

# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk180
export JAVA_HOME

# set groovy home environment variables.
GROOVY_HOME=/usr/local/apache/${groovyhome}
export GROOVY_HOME
PATH=${GROOVY_HOME}/bin:${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
groovy --version
