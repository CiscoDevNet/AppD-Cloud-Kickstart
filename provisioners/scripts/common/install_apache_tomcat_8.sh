#!/bin/sh -eux
# install tomcat 8 web server by apache.
# NOTE: This script is still a work-in-progress.

# set default values for input environment variables if not set. ---------------
# tomcat web server install parameters.
tomcat_home="${tomcat_home:-apache-tomcat-8}"                       # [optional] tomcat home (defaults to 'apache-tomcat-8').
tomcat_release="${tomcat_release:-8.5.40}"                          # [optional] tomcat release (defaults to '8.5.40').

tomcat_username="${tomcat_username:-ec2-user}"                      # [optional] tomcat user name (defaults to 'ec2-user').
tomcat_group="${tomcat_group:-ec2-user}"                            # [optional] tomcat group (defaults to 'ec2-user').

tomcat_admin_username="${tomcat_admin_username:-admin}"             # [optional] tomcat admin user name (defaults to 'admin').
tomcat_admin_password="${tomcat_admin_password:-welcome1}"          # [optional] tomcat admin password (defaults to 'welcome1').
tomcat_admin_roles="${tomcat_admin_roles:-manager-gui,admin-gui}"   # [optional] tomcat admin roles (defaults to 'manager-gui,admin-gui').
                                                                    #            NOTE: for appd java agent, use 'manager-script'.
tomcat_jdk_home="${tomcat_jdk_home:-/usr/local/java/jdk180}"        # [optional] tomcat jdk home (defaults to '/usr/local/java/jdk180').
                                                                    # [optional] tomcat catalina opts (defaults to '-Xms512M -Xmx1024M -server -XX:+UseParallelGC').
                                                                    #            NOTE: for appd java agent, add '-javaagent:/opt/appdynamics/appagent/javaagent.jar'.
tomcat_catalina_opts="${tomcat_catalina_opts:--Xms512M -Xmx1024M -server -XX:+UseParallelGC}"
                                                                    # [optional] tomcat java opts (defaults to '-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom').
tomcat_java_opts="${tomcat_java_opts:--Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom}"

# define usage function. -------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
   # tomcat web server install parameters.
    [root]# export tomcat_home="apache-tomcat-8"                # [optional] tomcat home (defaults to 'apache-tomcat-8').
    [root]# export tomcat_release="8.5.40"                      # [optional] tomcat release (defaults to '8.5.40').
   #
    [root]# export tomcat_username="ec2-user"                   # [optional] tomcat user name (defaults to 'ec2-user').
    [root]# export tomcat_group="ec2-user"                      # [optional] tomcat group (defaults to 'ec2-user').
   #
    [root]# export tomcat_admin_username="admin"                # [optional] tomcat admin user name (defaults to 'admin').
    [root]# export tomcat_admin_password="welcome1"             # [optional] tomcat admin password (defaults to 'welcome1').
    [root]# export tomcat_admin_roles="manager-gui,admin-gui"   # [optional] tomcat admin roles (defaults to 'manager-gui,admin-gui').
                                                                #            NOTE: for appd java agent, use 'manager-script'.
    [root]# export tomcat_jdk_home="/usr/local/java/jdk180"     # [optional] tomcat jdk home (defaults to '/usr/local/java/jdk180').
                                                                # [optional] tomcat catalina opts (defaults to '-Xms512M -Xmx1024M -server -XX:+UseParallelGC').
                                                                #            NOTE: for appd java agent, add '-javaagent:/opt/appdynamics/appagent/javaagent.jar'.
    [root]# export tomcat_catalina_opts="-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
                                                                # [optional] tomcat java opts (defaults to '-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom').
    [root]# export tomcat_java_opts="-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"
    [root]# $0
EOF
}

# install apache tomcat. -------------------------------------------------------
# set tomcat web server installation variables.
tomcat_folder="${tomcat_home:0:-2}-${tomcat_release}"
tomcat_binary="${tomcat_folder}.tar.gz"

# create apache parent folder.
mkdir -p /usr/local/apache
cd /usr/local/apache

# download tomcat binary from apache.org.
wget --no-verbose http://archive.apache.org/dist/tomcat/${tomcat_home:7}/v${tomcat_release}/bin/${tomcat_binary}

# extract tomcat binary.
rm -f ${tomcat_home}
tar -zxvf ${tomcat_binary} --no-same-owner --no-overwrite-dir
chown -R ${tomcat_username}:${tomcat_group} ./${tomcat_folder}
ln -s ${tomcat_folder} ${tomcat_home}
rm -f ${tomcat_binary}

# set jdk home environment variables.
JAVA_HOME=${tomcat_jdk_home}
export JAVA_HOME

# set tomcat home environment variables.
CATALINA_HOME=/usr/local/apache/${tomcat_home}
export CATALINA_HOME
CATALINA_BASE=${CATALINA_HOME}
export CATALINA_BASE
PATH=${JAVA_HOME}/bin:$PATH
export PATH

# verify installation.
if [ -d "$CATALINA_HOME" ]; then
  cd ${CATALINA_HOME}/bin
  ./version.sh
fi

# configure the tomcat 'setenv.sh' script. -------------------------------------
setenv_dir="${CATALINA_HOME}/bin"
setenv_filename="setenv.sh"
setenv_filepath="${setenv_dir}/${setenv_filename}"

# create 'setenv.sh' environment variable file.
if [ -d "$setenv_dir" ]; then
  rm -f "${setenv_filepath}"

  touch "${setenv_filepath}"
  chmod 755 "${setenv_filepath}"
  chown ${tomcat_username}:${tomcat_group} "${setenv_filepath}"

  echo "#!/bin/sh" >> "${setenv_filepath}"
  echo "#Set environment variables for the Apache Tomcat ${tomcat_home:${#tomcat_home}-1:1} web server." >> "${setenv_filepath}"
  echo "JAVA_HOME=\"${JAVA_HOME}\"" >> "${setenv_filepath}"
  echo "CATALINA_PID=\"${CATALINA_HOME}/tomcat.pid\"" >> "${setenv_filepath}"
  echo "CATALINA_OPTS=\"\${CATALINA_OPTS} ${tomcat_catalina_opts}\"" >> "${setenv_filepath}"
  echo "#CATALINA_OPTS=\"\${CATALINA_OPTS} -javaagent:/opt/appdynamics/appagent/javaagent.jar\"" >> "${setenv_filepath}"
  echo "JAVA_OPTS=\"\${JAVA_OPTS} ${tomcat_java_opts}\"" >> "${setenv_filepath}"
fi

# configure the tomcat users file. ---------------------------------------------
if [ -d "${CATALINA_HOME}/conf" ]; then
  cd ${CATALINA_HOME}/conf

  # save a copy of the original file.
  tomcat_users_file="tomcat-users.xml"
  cp -p ${tomcat_users_file} ${tomcat_users_file}.orig

  # add entry for a new user before the last line of the file as in this example:
  #   <user username="admin" password="welcome1" roles="manager-gui,admin-gui"/>
  tomcat_search_string="<\/tomcat-users>"
  tomcat_user_string="  <user username=\\\"${tomcat_admin_username}\\\" password=\\\"${tomcat_admin_password}\\\" roles=\\\"${tomcat_admin_roles}\\\"\/>"
  sed -i "s/^${tomcat_search_string}/${tomcat_user_string}\n${tomcat_search_string}/g" ${tomcat_users_file}
fi

# configure the tomcat web server as a service. --------------------------------
systemd_dir="/etc/systemd/system"
tomcat_service="${tomcat_home}.service"
service_filepath="${systemd_dir}/${tomcat_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"

  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The Apache Tomcat ${tomcat_home:${#tomcat_home}-1:1} web server." >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "Type=forking" >> "${service_filepath}"
  echo "User=${tomcat_username}" >> "${service_filepath}"
  echo "Group=${tomcat_group}" >> "${service_filepath}"
  echo "Environment=JAVA_HOME=${JAVA_HOME}" >> "${service_filepath}"
  echo "Environment=CATALINA_HOME=${CATALINA_HOME}" >> "${service_filepath}"
  echo "Environment=CATALINA_BASE=${CATALINA_BASE}" >> "${service_filepath}"
  echo "RemainAfterExit=true" >> "${service_filepath}"
  echo "ExecStart=${CATALINA_HOME}/bin/startup.sh" >> "${service_filepath}"
  echo "ExecStop=${CATALINA_HOME}/bin/shutdown.sh" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

# enable the controller service to start at boot time.
systemctl enable "${tomcat_service}"
systemctl is-enabled "${tomcat_service}"

# check current status.
#systemctl status "${tomcat_service}"

