#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Apache Tomcat 10.1.x Web Server by Apache on RHEL-based Linux 7.x distros.
#
# Apache Tomcat is an open source software implementation of a subset of the Jakarta EE (formally
# Java EE) technologies. Apache Tomcat 10.1.x builds on Tomcat 10.0.x and implements the
# Servlet 6.0, JSP 3.1, EL 5.0, WebSocket 2.1 and Authentication 3.0 specifications (the versions
# required by Java EE 10 platform).
#
# Tomcat 10.1 was designed to run on Java SE 11 or later.
#
# For more details, please visit:
#   https://tomcat.apache.org/tomcat-10.1-doc/index.html
#   https://tomcat.apache.org/download-10.cgi
#   https://tomcat.apache.org/whichversion.html
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] tomcat web server install parameters [w/ defaults].
tomcat_home="${tomcat_home:-apache-tomcat-10.1}"                    # [optional] tomcat home (defaults to 'apache-tomcat-10.1').
tomcat_release="${tomcat_release:-10.1.26}"                         # [optional] tomcat release (defaults to '10.1.26').
                                                                    # [optional] tomcat sha-512 checksum (defaults to published value).
tomcat_sha512="${tomcat_sha512:-0a62e55c1ff9f8f04d7aff938764eac46c289eda888abf43de74a82ceb7d879e94a36ea3e5e46186bc231f07871fcc4c58f11e026f51d4487a473badb21e9355}"
tomcat_username="${tomcat_username:-centos}"                        # [optional] tomcat user name (defaults to 'centos').
tomcat_group="${tomcat_group:-centos}"                              # [optional] tomcat group (defaults to 'centos').

# [OPTIONAL] tomcat web server config parameters [w/ defaults].
tomcat_admin_username="${tomcat_admin_username:-admin}"             # [optional] tomcat admin user name (defaults to 'admin').
set +x  # temporarily turn command display OFF.
tomcat_admin_password="${tomcat_admin_password:-welcome1}"          # [optional] tomcat admin password (defaults to 'welcome1').
set -x  # turn command display back ON.
tomcat_admin_roles="${tomcat_admin_roles:-manager-gui,admin-gui}"   # [optional] tomcat admin roles (defaults to 'manager-gui,admin-gui').
                                                                    #            NOTE: for appd java agent, add 'manager-script'.
tomcat_jdk_home="${tomcat_jdk_home:-/usr/local/java/jdk11}"         # [optional] tomcat jdk home (defaults to '/usr/local/java/jdk11').
                                                                    # [optional] tomcat catalina opts (defaults to '-Xms512M -Xmx1024M -server -XX:+UseParallelGC').
                                                                    #            NOTE: for appd java agent, add '-javaagent:/opt/appdynamics/appagent/javaagent.jar'.
tomcat_catalina_opts="${tomcat_catalina_opts:--Xms512M -Xmx1024M -server -XX:+UseParallelGC}"
                                                                    # [optional] tomcat java opts (defaults to '-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom').
tomcat_java_opts="${tomcat_java_opts:--Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom}"
tomcat_enable_service="${tomcat_enable_service:-true}"              # [optional] enable tomcat service (defaults to 'true').
                                                                    # [optional] allow remote access for tomcat manager apps (defaults to 'true').
tomcat_manager_apps_remote_access="${tomcat_manager_apps_remote_access:-true}"

# install apache tomcat. ---------------------------------------------------------------------------
# set tomcat web server installation variables.
tomcat_folder="${tomcat_home:0:-5}-${tomcat_release}"
tomcat_binary="${tomcat_folder}.tar.gz"

# create apache parent folder.
mkdir -p /usr/local/apache
cd /usr/local/apache

# download tomcat binary from apache.org.
wget --no-verbose https://archive.apache.org/dist/tomcat/${tomcat_home:7:-2}/v${tomcat_release}/bin/${tomcat_binary}

# verify the downloaded binary.
echo "${tomcat_sha512} ${tomcat_binary}" | sha512sum --check
# ${tomcat_folder}.tar.gz: OK

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

# configure the tomcat 'setenv.sh' script. ---------------------------------------------------------
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
  echo "#Set environment variables for the Apache Tomcat ${tomcat_home:${#tomcat_home}-4:4} web server." >> "${setenv_filepath}"
  echo "JAVA_HOME=\"${JAVA_HOME}\"" >> "${setenv_filepath}"
  echo "CATALINA_PID=\"${CATALINA_HOME}/tomcat.pid\"" >> "${setenv_filepath}"
  echo "CATALINA_OPTS=\"\${CATALINA_OPTS} ${tomcat_catalina_opts}\"" >> "${setenv_filepath}"
  echo "#CATALINA_OPTS=\"\${CATALINA_OPTS} -javaagent:/opt/appdynamics/appagent/javaagent.jar\"" >> "${setenv_filepath}"
  echo "JAVA_OPTS=\"\${JAVA_OPTS} ${tomcat_java_opts}\"" >> "${setenv_filepath}"
fi

# configure the tomcat users file. -----------------------------------------------------------------
if [ -d "${CATALINA_HOME}/conf" ]; then
  cd ${CATALINA_HOME}/conf

  # save a copy of the original file.
  tomcat_users_file="tomcat-users.xml"
  cp -p ${tomcat_users_file} ${tomcat_users_file}.orig

  # add entries for a new user before the last line of the file as in this example:
  #   <role rolename="manager-gui"/>
  #   <role rolename="admin-gui"/>
  #   <user username="admin" password="welcome1" roles="manager-gui,admin-gui"/>
  tomcat_search_string="<\/tomcat-users>"
  set +x  # temporarily turn command display OFF.
  tomcat_user_string="  <user username=\\\"${tomcat_admin_username}\\\" password=\\\"${tomcat_admin_password}\\\" roles=\\\"${tomcat_admin_roles}\\\"\/>"
  set -x  # turn command display back ON.
  tomcat_admin_roles_array=( $(echo $tomcat_admin_roles | tr ',' ' ') )

# loop to add role entries for the new user before the last line of the file.
# echo "Number of Tomcat Roles: ${#tomcat_admin_roles_array[@]}"
  for tomcat_admin_role in "${tomcat_admin_roles_array[@]}"; do
#   echo "Tomcat Role: ${tomcat_admin_role}"
    tomcat_role_string="  <role rolename=\\\"${tomcat_admin_role}\\\"\/>"
    sed -i "s/^${tomcat_search_string}/${tomcat_role_string}\n${tomcat_search_string}/g" ${tomcat_users_file}
  done

# add user entry with the specified roles before the last line of the file.
  set +x  # temporarily turn command display OFF.
  sed -i "s/^${tomcat_search_string}/${tomcat_user_string}\n${tomcat_search_string}/g" ${tomcat_users_file}
  set -x  # turn command display back ON.
fi

# configure the tomcat manager apps context files for remote access. -------------------------------
if [ "$tomcat_manager_apps_remote_access" == "true" ]; then
  # initialize tomcat manager apps array.
  tomcat_manager_apps_array=( "manager" "host-manager" )

  # loop for each tomcat manager app.
  for tomcat_manager_app in "${tomcat_manager_apps_array[@]}"; do

    if [ -d "${CATALINA_HOME}/webapps/${tomcat_manager_app}/META-INF" ]; then
      cd ${CATALINA_HOME}/webapps/${tomcat_manager_app}/META-INF

      # save a copy of the original file.
      tomcat_context_file="context.xml"
      cp -p ${tomcat_context_file} ${tomcat_context_file}.orig

      # enable remote access for the tomcat manager app by commenting out the '<Valve/>' element:
      #   <!--
      #   <Valve className="org.apache.catalina.valves.RemoteAddrValve"
      #          allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
      #   -->

      # add xml begin comment string.
      tomcat_begin_search_string=".*Valve.*"
      tomcat_begin_comment_string="  <\!--"
      sed -i "s/^${tomcat_begin_search_string}/${tomcat_begin_comment_string}\n&/g" ${tomcat_context_file}

      # add xml end comment string.
      tomcat_end_search_string=".*allow.*"
      tomcat_end_comment_string="  -->"
      sed -i "s/^${tomcat_end_search_string}/&\n${tomcat_end_comment_string}/g" ${tomcat_context_file}
    fi
  done
fi

# configure the tomcat web server as a service. ----------------------------------------------------
systemd_dir="/etc/systemd/system"
tomcat_service="${tomcat_home}.service"
service_filepath="${systemd_dir}/${tomcat_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"

  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The Apache Tomcat ${tomcat_home:${#tomcat_home}-4:4} web server." >> "${service_filepath}"
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

# enable the controller service to start at boot time, if 'true'.
if [ "$tomcat_enable_service" == "true" ]; then
  systemctl enable "${tomcat_service}"
else
  systemctl disable "${tomcat_service}"
fi

# confirm enable status.
set +e  # temporarily turn 'exit pipeline on non-zero return status' OFF.
systemctl is-enabled "${tomcat_service}"
set -e  # turn 'exit pipeline on non-zero return status' back ON.

# check current status.
#systemctl status "${tomcat_service}"
