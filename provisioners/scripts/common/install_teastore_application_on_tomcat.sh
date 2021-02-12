#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install TeaStore microservice application on Apache Tomcat 8.5+.
#
# The TeaStore is a microservice reference and test application to be used in benchmarks and
# tests. The TeaStore emulates a basic web store for automatically generated tea and tea supplies.
# As it is primarily a test application, it features UI elements for database generation and
# service resetting in addition to the store itself.
#
# The TeaStore's persistence services use a MySQL/MariaDB database. The database host and port
# must be configured in the Java environment of all containers running persistence services,
# unless running on 'localhost:3306'. In addition, all containers running persistence services must
# have a MySQL/MariaDB driver (Java connector) installed. The store automatically creates the
# required tables and resets them using the web UI.
#
# The following is a summary of the required database settings:
#
#   Default Host:      localhost    # Can be changed in Java environment (context.xml).
#   Default Port:      3306         # Can be changed in Java environment (context.xml).
#   Database name:     teadb
#   Database user:     teauser      # Must have all privileges on 'teadb'.
#   Database password: teapassword
#
# For more details, please visit:
#   https://github.com/DescartesResearch/TeaStore
#   https://github.com/DescartesResearch/TeaStore/wiki/Getting-Started
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] mariadb server install parameters [w/ defaults].
set +x  # temporarily turn command display OFF.
mariadb_server_root_password="${mariadb_server_root_password:-Password1234!}"   # [optional] root password (defaults to 'Password1234!').
set -x  # turn command display back ON.

# [OPTIONAL] mysql driver (java connector) install parameters [w/ defaults].
mysql_java_connector_release="${mysql_java_connector_release:-8.0.23}"          # [optional] mysql java connector release (defaults to '8.0.23').
mysql_java_connector_md5="0856fa2e627c7ee78019cd0980d04614"                     # [optional] mysql java connector md5 checksum (defaults to published value).

# [OPTIONAL] tomcat web server install parameters [w/ defaults].
tomcat_home="${tomcat_home:-apache-tomcat-8}"                                   # [optional] tomcat home (defaults to 'apache-tomcat-8').
tomcat_username="${tomcat_username:-centos}"                                    # [optional] tomcat user name (defaults to 'centos').
tomcat_group="${tomcat_group:-centos}"                                          # [optional] tomcat group (defaults to 'centos').

# import teastore application project from github.com. ---------------------------------------------
# create teastore application project parent folder.
mkdir -p /usr/local/src
cd /usr/local/src

# download teastore application project from github.com.
rm -Rf ./TeaStore
git clone https://github.com/DescartesResearch/TeaStore.git
cd /usr/local/src/TeaStore
git fetch origin

# create teastore application database and user from source. ---------------------------------------
# check that the mariadb service is running.
mariadb_server_is_running=$(pgrep mariadb | wc -l)
if [ "${mariadb_server_is_running}" -ne 1 ]; then
  systemctl start mariadb
fi

# change to the teastore application sql scripts directory.
cd /usr/local/src/TeaStore/utilities/tools.descartes.teastore.database

# create the teastore database and user.
set +x  # temporarily turn command display OFF.
mariadb -u root -p${mariadb_server_root_password} < setup.sql
set -x  # turn command display back ON.

# verify schema initialization.
mariadb -u root -p${mariadb_server_root_password} -e 'show databases;'
set -x  # turn command display back ON.
echo "TeaStore application database and user creation complete."

# build teastore services and registry war files from source. --------------------------------------
cd /usr/local/src/TeaStore

# set jdk home environment variables.
JAVA_HOME=/usr/local/java/jdk180
export JAVA_HOME

# set maven home environment variables.
M2_HOME=/usr/local/apache/apache-maven
export M2_HOME
M2_REPO=$HOME/.m2
export M2_REPO
MAVEN_OPTS=-Dfile.encoding="UTF-8"
export MAVEN_OPTS
M2=$M2_HOME/bin
export M2
PATH=${M2}:${JAVA_HOME}/bin:$PATH
export PATH

# verify maven version.
mvn --version

# build the teastore war files.
mvn clean install

# create images folder for teastore application. ---------------------------------------------------
# change ownership to tomcat user and group.
rm -Rf /images
mkdir -p /images
chown ${tomcat_username}:${tomcat_group} /images

# shutdown tomcat application server prior to deployment and configuration. ------------------------
# shutdown tomcat server.
systemctl stop ${tomcat_home}

# download and install the mysql driver (java connector) to tomcat. --------------------------------
mysql_java_connector_binary="mysql-connector-java-${mysql_java_connector_release}.tar.gz"
mysql_java_connector_folder="mysql-connector-java-${mysql_java_connector_release}"
mysql_java_connector_jar="mysql-connector-java-${mysql_java_connector_release}.jar"

# create mysql java connector parent folder.
cd /usr/local/src
rm -Rf ${mysql_java_connector_folder}
mkdir -p /usr/local/src/${mysql_java_connector_folder}

# download the mysql java connector.
cd /usr/local/src/${mysql_java_connector_folder}
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://dev.mysql.com/get/Downloads/Connector-J/${mysql_java_connector_binary}

# verify the downloaded binary using the md5 checksum.
echo "${mysql_java_connector_md5} ${mysql_java_connector_binary}" | md5sum --check -
# mysql-connector-java-${mysql_java_connector_release}.tar.gz: OK

# extract and copy the mysql java connector jar file to the tomcat 'lib' folder.
tar -zxvf ${mysql_java_connector_binary} ${mysql_java_connector_folder}/${mysql_java_connector_jar}
cp ${mysql_java_connector_folder}/${mysql_java_connector_jar} /usr/local/apache/${tomcat_home}/lib

# change ownership to tomcat user and group.
cd /usr/local/apache/${tomcat_home}/lib
chown ${tomcat_username}:${tomcat_group} ./${mysql_java_connector_jar}

# copy the teastore services and registry war files from target directory. -------------------------
cd /usr/local/apache/${tomcat_home}/webapps
rm -f ./tools.descartes.teastore.*.war
cp /usr/local/src/TeaStore/utilities/tools.descartes.teastore.docker.all/target/tools.descartes.teastore.*.war .

# change ownership to tomcat user and group.
chown ${tomcat_username}:${tomcat_group} ./tools.descartes.teastore.*.war

# use the stream editor to substitute the new values into the tomcat config. -----------------------
tomcat_config_file="context.xml"
cd /usr/local/apache/${tomcat_home}/conf
cp -p ${tomcat_config_file} ${tomcat_config_file}.orig

# define stream editor search strings.
tomcat_config_search_01="^    <!--$"
tomcat_config_search_02="^    -->$"
tomcat_config_search_03="    <!-- Uncomment this to disable session persistence across Tomcat restarts -->"

# define stream editor teastore config substitution strings.
teastore_config_line_01="    <!-- TeaStore service registration settings. Almost always required. -->"
teastore_config_line_02="    <Environment name=\"servicePort\" value=\"8080\" type=\"java.lang.String\" override=\"false\" \/>"
teastore_config_line_03="    <Environment name=\"hostName\" value=\"localhost\" type=\"java.lang.String\" override=\"false\" \/>"
teastore_config_line_04="    <Environment name=\"registryURL\""
teastore_config_line_05="                 value=\"http:\/\/localhost:8080\/tools.descartes.teastore.registry\/rest\/services\/\""
teastore_config_line_06="                 type=\"java.lang.String\""
teastore_config_line_07="                 override=\"false\" \/>"
teastore_config_line_08=""
teastore_config_line_09="    <!-- TeaStore database settings. Specify if not running on 'localhost:3306'. -->"
teastore_config_line_10="    <!--"
teastore_config_line_11="    <Environment name=\"databaseHost\" value=\"localhost\" type=\"java.lang.String\" override=\"false\" \/>"
teastore_config_line_12="    <Environment name=\"databasePort\" value=\"3306\" type=\"java.lang.String\" override=\"false\" \/>"
teastore_config_line_13="    -->"
teastore_config_line_14=""
teastore_config_line_15="    <!-- General Tomcat setting: Disable session persistence to improve startup times. -->"

# delete comment elements ('<!--' and '-->') around '<Manager pathname="" />' to disable session persistence.
sed -i -e "/${tomcat_config_search_01}/d" ${tomcat_config_file}
sed -i -e "/${tomcat_config_search_02}/d" ${tomcat_config_file}

# insert teastore config lines before this comment: '<!-- Uncomment this to disable session persistence across Tomcat restarts -->'.
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_01}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_02}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_03}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_04}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_05}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_06}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_07}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_08}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_09}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_10}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_11}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_12}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_13}\n${tomcat_config_search_03}/g" ${tomcat_config_file}
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_14}\n${tomcat_config_search_03}/g" ${tomcat_config_file}

# replace original comment with this: '<!-- General Tomcat setting: Disable session persistence to improve startup times. -->'.
sed -i -e "s/${tomcat_config_search_03}/${teastore_config_line_15}/g" ${tomcat_config_file}

# validate new tomcat config file.
cat ${tomcat_config_file}

# restart tomcat application server to apply changes. ----------------------------------------------
# start the tomcat server.
#systemctl start ${tomcat_home}

# check current status.
#systemctl status "${tomcat_home}"
