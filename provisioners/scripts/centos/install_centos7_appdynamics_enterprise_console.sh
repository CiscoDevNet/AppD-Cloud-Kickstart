#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Enterprise Console by AppDynamics.
#
# The Enterprise Console is the installer for the Controller and Events Service. You can use
# it to install and manage the entire lifecycle of new or existing on-premises AppDynamics
# Platforms and components. The application provides a GUI and command line interface.
#
# For more details, please visit:
#   https://docs.appdynamics.com/latest/en/application-performance-monitoring-platform/enterprise-console
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set local installation variables. ----------------------------------------------------------------
local_hostname="$(hostname --short)"                            # initialize short hostname.
#local_hostname="$(uname -n)"                                    # initialize hostname.

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics platform install parameters [w/ defaults].
# appd platform install parameters.
appd_home="${appd_home:-/opt/appdynamics}"
appd_platform_home="${appd_platform_home:-platform}"
appd_platform_release="${appd_platform_release:-21.4.12.24706}"
appd_platform_sha256="${appd_platform_sha256:-634a866fb8ea04499a36b04cf287020a8bcef4111cbbccb8ad5199c91701539c}"
appd_platform_user_name="${appd_platform_user_name:-centos}"
appd_platform_user_group="${appd_platform_user_group:-centos}"
set +x  # temporarily turn command display OFF.
appd_platform_admin_username="${appd_platform_admin_username:-admin}"
appd_platform_admin_password="${appd_platform_admin_password:-welcome1}"
appd_platform_db_password="${appd_platform_db_password:-welcome1}"
appd_platform_db_root_password="${appd_platform_db_root_password:-welcome1}"
set -x  # turn command display back ON.
appd_platform_server_host="${appd_platform_server_host:-$local_hostname}"
appd_platform_server_port="${appd_platform_server_port:-9191}"
appd_platform_use_https="${appd_platform_use_https:-false}"

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Enterprise Console by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_platform_home="platform"                        # [optional] platform home folder (defaults to 'platform').
    [root]# export appd_platform_release="21.4.12.24706"                # [optional] platform release (defaults to '21.4.12.24706').
                                                                        # [optional] platform sha-256 checksum (defaults to published value).
    [root]# export appd_platform_sha256="634a866fb8ea04499a36b04cf287020a8bcef4111cbbccb8ad5199c91701539c"
    [root]# export appd_platform_user_name="centos"                     # [optional] platform user name (defaults to 'centos').
    [root]# export appd_platform_user_group="centos"                    # [optional] platform group (defaults to 'centos').
    [root]# export appd_platform_admin_username="admin"                 # [optional] platform admin user name (defaults to user 'admin').
    [root]# export appd_platform_admin_password="welcome1"              # [optional] platform admin password (defaults to 'welcome1').
    [root]# export appd_platform_db_password="welcome1"                 # [optional] platform database password (defaults to 'welcome1').
    [root]# export appd_platform_db_root_password="welcome1"            # [optional] platform database root password (defaults to 'welcome1').
    [root]# export appd_platform_server_host="apm.localdomain"          # [optional] platform server hostname (defaults to 'uname -n').
    [root]# export appd_platform_server_port="9191"                     # [optional] platform server port (defaults to '9191').
    [root]# export appd_platform_use_https="false"                      # [optional] platform use https [boolean] (defaults to 'false').

  [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
    [root]# export kickstart_home="/opt/appd-cloud-kickstart"           # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

  --------
  Example:
  --------
    [root]# $0
EOF
}

# set appdynamics platform installation variables. -------------------------------------------------
appd_platform_folder="${appd_home}/${appd_platform_home}"
appd_platform_installer="platform-setup-x64-linux-${appd_platform_release}.sh"

# install platform prerequisites. ------------------------------------------------------------------
# install network tools.
yum -y install net-tools libaio numactl tzdata

# check linux distro and install correct ui tools.
# note: mysql 5.5.57 and 5.7.19 require ncurses-libs version 5, which is NOT
#       the default on amazon linux 2, centos 8, and red hat enterprise linux 8.
distro_name=$(cat /etc/system-release | awk 'NR==1 {print $1}')
version_name=$(cat /etc/os-release | awk -F '"' '/^VERSION_ID/ {print $2}')
if ([ "$distro_name" = "Amazon" ] && [ "${version_name}" = "2" ]) || \
   ([ "$distro_name" = "CentOS" ] && [ "${version_name:0:1}" = "8" ]) || \
   ([ "$distro_name" = "Red" ] && [ "${version_name:0:1}" = "8" ]); then
  # force install of ncurses 5 packages.
  ncurses_5_base_package="ncurses-base-5.9-14.20130511.el7_4.noarch.rpm"
  ncurses_5_libs_package="ncurses-libs-5.9-14.20130511.el7_4.x86_64.rpm"
  rm -f ${ncurses_5_base_package}
  curl --silent --location "http://mirror.centos.org/centos/7/os/x86_64/Packages/${ncurses_5_base_package}" --output ${ncurses_5_base_package}
  rpm -ivh --force ${ncurses_5_base_package}

  rm -f ${ncurses_5_libs_package}
  curl --silent --location "http://mirror.centos.org/centos/7/os/x86_64/Packages/${ncurses_5_libs_package}" --output ${ncurses_5_libs_package}
  rpm -ivh --force ${ncurses_5_libs_package}
else
  # for all other distros, install standard ncurses 5 packages.
  yum -y install ncurses-libs
fi

# configure file and process limits for user 'root'.
echo "Displaying current file and process limits for user \"root\"..."
ulimit -S -n
ulimit -S -u

if [ "$appd_platform_user_name" != "root" ]; then
  echo "Displaying current file and process limits for user \"${appd_platform_user_name}\"..."
  runuser -c "ulimit -S -n" - ${appd_platform_user_name}
  runuser -c "ulimit -S -u" - ${appd_platform_user_name}
fi

user_limits_dir="/etc/security/limits.d"
appd_conf="appdynamics.conf"
num_file_descriptors="65535"
num_processes="8192"

if [ -d "$user_limits_dir" ]; then
  rm -f "${user_limits_dir}/${appd_conf}"
  touch "${user_limits_dir}/${appd_conf}"
  chmod 644 "${user_limits_dir}/${appd_conf}"

  echo "root hard nofile ${num_file_descriptors}" >> "${user_limits_dir}/${appd_conf}"
  echo "root soft nofile ${num_file_descriptors}" >> "${user_limits_dir}/${appd_conf}"
  echo "root hard nproc ${num_processes}" >> "${user_limits_dir}/${appd_conf}"
  echo "root soft nproc ${num_processes}" >> "${user_limits_dir}/${appd_conf}"

  if [ "$appd_platform_user_name" != "root" ]; then
    echo "${appd_platform_user_name} hard nofile ${num_file_descriptors}" >> "${user_limits_dir}/${appd_conf}"
    echo "${appd_platform_user_name} soft nofile ${num_file_descriptors}" >> "${user_limits_dir}/${appd_conf}"
    echo "${appd_platform_user_name} hard nproc ${num_processes}" >> "${user_limits_dir}/${appd_conf}"
    echo "${appd_platform_user_name} soft nproc ${num_processes}" >> "${user_limits_dir}/${appd_conf}"
  fi
fi

# add user limits to the pluggable authentication modules (pam).
pam_dir="/etc/pam.d"
session_conf="common-session"
session_cmd="session required pam_limits.so"
if [ -d "$pam_dir" ]; then
  if [ -f "${pam_dir}/${session_conf}" ]; then
    grep -qF "${session_cmd}" "${pam_dir}/${session_conf}" || echo "${session_cmd}" >> "${pam_dir}/${session_conf}"
  else
    echo "${session_cmd}" > "${pam_dir}/${session_conf}"
  fi
fi

# set current file and process limits.
echo "Setting current file and process limits for user \"root\"..."
ulimit -n ${num_file_descriptors}
ulimit -u ${num_processes}

if [ "$appd_platform_user_name" != "root" ]; then
  echo "Setting current file and process limits for user \"${appd_platform_user_name}\"..."
  runuser -c "ulimit -n ${num_file_descriptors}" - ${appd_platform_user_name}
  runuser -c "ulimit -u ${num_processes}" - ${appd_platform_user_name}
fi

# verify current file and process limits.
echo "Verifying current file and process limits for user \"root\"..."
ulimit -S -n
ulimit -S -u

# verify file and process limits for new processes.
echo "Verifying file and process limits for new processes for user \"root\"..."
runuser -c "ulimit -S -n" -
runuser -c "ulimit -S -u" -

if [ "$appd_platform_user_name" != "root" ]; then
  echo "Verifying file and process limits for new processes for user \"${appd_platform_user_name}\"..."
  runuser -c "ulimit -S -n" - ${appd_platform_user_name}
  runuser -c "ulimit -S -u" - ${appd_platform_user_name}
fi

# increase the limits on virtual memory mapping. (needed by the new elasticsearch configuration.)
sysctlfile="/etc/sysctl.conf"
maxmapcount="vm.max_map_count=262144"
if [ -f "$sysctlfile" ]; then
  sysctl vm.max_map_count
  grep -qF "${maxmapcount}" ${sysctlfile} || echo "${maxmapcount}" >> ${sysctlfile}
  sysctl -p /etc/sysctl.conf
  sysctl vm.max_map_count
fi

# create temporary download directory. -------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos/appdynamics
cd ${kickstart_home}/provisioners/scripts/centos/appdynamics

# create appd home directory and change ownership to platform user name and group. -----------------
mkdir -p ${appd_home}

if [ "$appd_platform_user_name" != "root" ]; then
  chown -R ${appd_platform_user_name}:${appd_platform_user_group} ${appd_home}
fi

# download the appdynamics platform installer. -----------------------------------------------------
# download the installer.
rm -f ${appd_platform_installer}
curl --silent --location --remote-name https://download-files.appdynamics.com/download-file/enterprise-console/${appd_platform_release}/${appd_platform_installer}
chmod 755 ${appd_platform_installer}

# verify the downloaded binary.
echo "${appd_platform_sha256} ${appd_platform_installer}" | sha256sum --check
# platform-setup-x64-linux-${appd_platform_release}.sh: OK

# create silent response file for installer. -------------------------------------------------------
response_file="appd-platform-response.varfile"

rm -f "${response_file}"
touch "${response_file}"
chmod 644 "${response_file}"

echo "serverHostName=${appd_platform_server_host}" >> "${response_file}"
echo "sys.languageId=en" >> "${response_file}"
echo "disableEULA=true" >> "${response_file}"
echo "platformAdmin.port=${appd_platform_server_port}" >> "${response_file}"
echo "platformAdmin.databasePort=3377" >> "${response_file}"
echo "platformAdmin.dataDir=${appd_platform_folder}/mysql/data" >> "${response_file}"
set +x  # temporarily turn command display OFF.
echo "platformAdmin.databasePassword=${appd_platform_db_password}" >> "${response_file}"
echo "platformAdmin.databaseRootPassword=${appd_platform_db_root_password}" >> "${response_file}"
echo "platformAdmin.adminUsername=${appd_platform_admin_username}" >> "${response_file}"
echo "platformAdmin.adminPassword=${appd_platform_admin_password}" >> "${response_file}"
set -x  # turn command display back ON.
echo "platformAdmin.useHttps\$Boolean=${appd_platform_use_https}" >> "${response_file}"
echo "sys.installationDir=${appd_platform_folder}" >> "${response_file}"

# install the appdynamics enterprise console. ------------------------------------------------------
# run the silent installer for linux.
runuser -c "${kickstart_home}/provisioners/scripts/centos/appdynamics/${appd_platform_installer} -q -varfile ${response_file}" - ${appd_platform_user_name}

# verify installation.
cd ${appd_platform_folder}/platform-admin/bin
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-platform-admin-version" - ${appd_platform_user_name}

# shutdown the appdynamics platform components. ----------------------------------------------------
# stop the appdynamics enterprise console.
runuser -c "${appd_platform_folder}/platform-admin/bin/platform-admin.sh stop-platform-admin" - ${appd_platform_user_name}

# configure the appdynamics enterprise console as a service. ---------------------------------------
systemd_dir="/etc/systemd/system"
appd_enterprise_console_service="appdynamics-enterprise-console.service"
service_filepath="${systemd_dir}/${appd_enterprise_console_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"
  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The AppDynamics Enterprise Console." >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "Type=forking" >> "${service_filepath}"

  if [ "$appd_platform_user_name" != "root" ]; then
    echo "User=${appd_platform_user_name}" >> "${service_filepath}"
    echo "Group=${appd_platform_user_group}" >> "${service_filepath}"
  fi

  echo "ExecStart=${appd_platform_folder}/platform-admin/bin/platform-admin.sh start-platform-admin" >> "${service_filepath}"
  echo "ExecStop=${appd_platform_folder}/platform-admin/bin/platform-admin.sh stop-platform-admin" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

# enable the enterprise console to start at boot time.
systemctl enable "${appd_enterprise_console_service}"
systemctl is-enabled "${appd_enterprise_console_service}"

# check current status.
#systemctl status "${appd_enterprise_console_service}"
