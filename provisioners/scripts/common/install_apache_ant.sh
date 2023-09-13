#!/bin/sh -eux
# install ant build tool by apache.

# set default value for kickstart home environment variable if not set. ----------------------------
#kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# install apache ant. ------------------------------------------------------------------------------
ant_home="apache-ant"
ant_release="1.10.14"
ant_folder="${ant_home}-${ant_release}"
ant_binary="${ant_folder}-bin.tar.gz"
ant_sha512="4e74b382dd8271f9eac9fef69ba94751fb8a8356dbd995c4d642f2dad33de77bd37d4001d6c8f4f0ef6789529754968f0c1b6376668033c8904c6ec84543332a"

# create apache parent folder.
mkdir -p /usr/local/apache
cd /usr/local/apache

# download ant binary from apache.org.
wget --no-verbose http://archive.apache.org/dist/ant/binaries/${ant_binary}

# verify the downloaded binary.
echo "${ant_sha512} ${ant_binary}" | sha512sum --check
# ${ant_folder}-bin.tar.gz: OK

# extract ant binary.
rm -f ${ant_home}
tar -zxvf ${ant_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${ant_folder}
ln -s ${ant_folder} ${ant_home}
rm -f ${ant_binary}

# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk180
export JAVA_HOME

# set ant home environment variables.
ANT_HOME=/usr/local/apache/${ant_home}
export ANT_HOME
PATH=${ANT_HOME}/bin:${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
ant -version

# install apache ant contrib. ----------------------------------------------------------------------
ant_contrib_folder="ant-contrib"
ant_contrib_release="1.0b3"
ant_contrib_binary="${ant_contrib_folder}-${ant_contrib_release}-bin.tar.gz"
ant_contrib_jar="${ant_contrib_folder}-${ant_contrib_release}.jar"

# create apache contrib parent folder.
mkdir -p /usr/local/apache
cd /usr/local/apache

# download ant contrib library from sourceforge.net.
curl --silent --location "https://sourceforge.net/projects/${ant_contrib_folder}/files/${ant_contrib_folder}/${ant_contrib_release}/${ant_contrib_binary}/download" --output ${ant_contrib_binary}
#cp -f ${kickstart_home}/provisioners/scripts/common/tools/${ant_contrib_binary} .

# extract ant contrib binary.
tar -zxvf ${ant_contrib_binary} --no-same-owner --no-overwrite-dir
chown -R root:root ./${ant_contrib_folder}
rm -f ${ant_contrib_binary}

# copy ant contrib library to apache-ant/lib.
cd /usr/local/apache/${ant_contrib_folder}
cp -p ${ant_contrib_jar} /usr/local/apache/${ant_home}/lib
