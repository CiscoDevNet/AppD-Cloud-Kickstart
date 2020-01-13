#!/bin/sh -eux
# install ant build tool by apache.

# set default value for kickstart home environment variable if not set. ----------------------------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# install apache ant. ------------------------------------------------------------------------------
anthome="apache-ant"
antrelease="1.10.7"
antfolder="${anthome}-${antrelease}"
antbinary="${antfolder}-bin.tar.gz"

# create apache parent folder.
mkdir -p /usr/local/apache
cd /usr/local/apache

# download ant binary from apache.org.
wget --no-verbose http://archive.apache.org/dist/ant/binaries/${antbinary}

# extract ant binary.
rm -f ${anthome}
tar -zxvf ${antbinary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${antfolder}
ln -s ${antfolder} ${anthome}
rm -f ${antbinary}

# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk180
export JAVA_HOME

# set ant home environment variables.
ANT_HOME=/usr/local/apache/${anthome}
export ANT_HOME
PATH=${ANT_HOME}/bin:${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
ant -version

# install apache ant contrib. ----------------------------------------------------------------------
acfolder="ant-contrib"
acrelease="1.0b3"
acbinary="${acfolder}-${acrelease}-bin.tar.gz"
acjar="${acfolder}-${acrelease}.jar"

# create apache contrib parent folder.
mkdir -p /usr/local/apache
cd /usr/local/apache

# download ant contrib library from sourceforge.net.
curl --silent --location "https://sourceforge.net/projects/${acfolder}/files/${acfolder}/${acrelease}/${acbinary}/download" --output ${acbinary}
#cp -f ${kickstart_home}/provisioners/scripts/common/tools/${acbinary} .

# extract ant contrib binary.
tar -zxvf ${acbinary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${acfolder}
rm -f ${acbinary}

# copy ant contrib library to apache-ant/lib.
cd /usr/local/apache/${acfolder}
cp -p ${acjar} /usr/local/apache/${anthome}/lib
