#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Enterprise Console by AppDynamics.
#
# The Enterprise Console is the installer for the Controller and Events Service. You can use
# it to install and manage the entire lifecycle of new or existing on-premises AppDynamics
# Platforms and components. The application provides a GUI and command line interface.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/LATEST/Enterprise+Console
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set local installation variables. ----------------------------------------------------------------
local_hostname="$(uname -n)"                                    # initialize hostname.

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] appdynamics account parameters.
set +x  # temporarily turn command display OFF.
appd_username="${appd_username:-}"
appd_password="${appd_password:-}"
set -x  # turn command display back ON.

# [OPTIONAL] appdynamics platform install parameters [w/ defaults].
# appd platform install parameters.
appd_home="${appd_home:-/opt/appdynamics}"
appd_platform_home="${appd_platform_home:-platform}"
appd_platform_release="${appd_platform_release:-20.4.0.22285}"
set +x  # temporarily turn command display OFF.
appd_platform_admin_username="${appd_platform_admin_username:-admin}"
appd_platform_admin_password="${appd_platform_admin_password:-welcome1}"
appd_platform_db_password="${appd_platform_db_password:-welcome1}"
appd_platform_db_root_password="${appd_platform_db_root_password:-welcome1}"
set -x  # turn command display back ON.
appd_platform_server_host="${appd_platform_server_host:-$local_hostname}"
appd_platform_server_port="${appd_platform_server_port:-9191}"

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
  [MANDATORY] appdynamics account parameters.
    [root]# export appd_username="name@example.com"                     # user name for downloading binaries.
    [root]# export appd_password="password"                             # user password.

  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_platform_home="platform"                        # [optional] platform home folder (defaults to 'platform').
    [root]# export appd_platform_release="20.4.0.22285"                 # [optional] platform release (defaults to '20.4.0.22285').
    [root]# export appd_platform_admin_username="admin"                 # [optional] platform admin user name (defaults to user 'admin').
    [root]# export appd_platform_admin_password="welcome1"              # [optional] platform admin password (defaults to 'welcome1').
    [root]# export appd_platform_db_password="welcome1"                 # [optional] platform database password (defaults to 'welcome1').
    [root]# export appd_platform_db_root_password="welcome1"            # [optional] platform database root password (defaults to 'welcome1').
    [root]# export appd_platform_server_host="apm"                      # [optional] platform server hostname (defaults to 'uname -n').
    [root]# export appd_platform_server_port="9191"                     # [optional] platform server port (defaults to '9191').

  [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
    [root]# export kickstart_home="/opt/appd-cloud-kickstart"           # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
set +x  # temporarily turn command display OFF.
if [ -z "$appd_username" ]; then
  echo "Error: 'appd_username' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_password" ]; then
  echo "Error: 'appd_password' environment variable not set."
  usage
  exit 1
fi
set -x  # turn command display back ON.

# set appdynamics platform installation variables. -------------------------------------------------
appd_platform_folder="${appd_home}/${appd_platform_home}"
appd_platform_installer="platform-setup-x64-linux-${appd_platform_release}.sh"
appd_platform_sha256="b542e333b3c5a15f98190645b572ae18c39577466076b2bf4b0cd1373b91ab59"

# install platform prerequisites. ------------------------------------------------------------------
# install the netstat network utility.
yum -y install net-tools

# install the asynchronous i/o library.
yum -y install libaio

# install the simple non-uniform memory access (numa) policy support package.
yum -y install numactl

# install the time zone data files with rules for various time zones around the world.
yum -y install tzdata

# install the ncurses (new curses) text-based ui library.
yum -y install ncurses-libs

# mysql 5.5.57 and 5.7.19 require ncurses-libs version 5, which is NOT the default on amazon linux 2.
# the 'ncurses-compat-libs' will install version 5 on amazon linux 2.
distro_name=$(cat /etc/system-release | awk 'NR==1 {print $1}')
if [ "$distro_name" = "Amazon" ]; then
  ncurses_library="/lib64/libtinfo.so.5"
  if [ ! -f "$ncurses_library" ]; then
    # works on amazon linux 2 only.
    yum -y install ncurses-compat-libs
  fi
fi

# configure file and process limits for user 'root'.
echo "Displaying current file and process limits..."
ulimit -S -n
ulimit -S -u

user_limits_dir="/etc/security/limits.d"
appd_conf="appdynamics.conf"
num_file_descriptors="65535"
num_processes="8192"

if [ -d "$user_limits_dir" ]; then
  rm -f "${user_limits_dir}/${appd_conf}"

  echo "root hard nofile ${num_file_descriptors}" > "${user_limits_dir}/${appd_conf}"
  echo "root soft nofile ${num_file_descriptors}" >> "${user_limits_dir}/${appd_conf}"
  echo "root hard nproc ${num_processes}" >> "${user_limits_dir}/${appd_conf}"
  echo "root soft nproc ${num_processes}" >> "${user_limits_dir}/${appd_conf}"
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
echo "Setting current file and process limits..."
ulimit -n ${num_file_descriptors}
ulimit -u ${num_processes}

# verify current file and process limits.
echo "Verifying current file and process limits..."
ulimit -S -n
ulimit -S -u

# verify file and process limits for new processes.
echo "Verifying file and process limits for new processes..."
runuser -c "ulimit -S -n" -
runuser -c "ulimit -S -u" -

# create temporary download directory. -------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos/appdynamics
cd ${kickstart_home}/provisioners/scripts/centos/appdynamics

# set current date for temporary filename. ---------------------------------------------------------
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# download the appdynamics platform installer. -----------------------------------------------------
# authenticate to the appdynamics domain and store the oauth token to a file.
post_data_filename="post-data.${curdate}.json"
oauth_token_filename="oauth-token.${curdate}.json"

rm -f "${post_data_filename}"
touch "${post_data_filename}"
chmod 644 "${post_data_filename}"

set +x  # temporarily turn command display OFF.
echo "{" >> ${post_data_filename}
echo "  \"username\": \"${appd_username}\"," >> ${post_data_filename}
echo "  \"password\": \"${appd_password}\"," >> ${post_data_filename}
echo "  \"scopes\": [\"download\"]" >> ${post_data_filename}
echo "}" >> ${post_data_filename}
set -x  # turn command display back ON.

curl --silent --request POST --data @${post_data_filename} https://identity.msrv.saas.appdynamics.com/v2.0/oauth/token --output ${oauth_token_filename}
oauth_token=$(awk -F '"' '{print $10}' ${oauth_token_filename})

# download the installer.
rm -f ${appd_platform_installer}
curl --silent --location --remote-name --header "Authorization: Bearer ${oauth_token}" https://download.appdynamics.com/download/prox/download-file/enterprise-console/${appd_platform_release}/${appd_platform_installer}
chmod 755 ${appd_platform_installer}

rm -f ${post_data_filename}
rm -f ${oauth_token_filename}

# verify the downloaded binary.
echo "${appd_platform_sha256} ${appd_platform_installer}" | sha256sum --check
# platform-setup-x64-linux-${appd_platform_release}.sh: OK

# create silent response file for installer. -------------------------------------------------------
response_file="appd-platform-response.varfile"

rm -f "${response_file}"

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
echo "platformAdmin.platformDir=${appd_platform_folder}" >> "${response_file}"

# install the appdynamics enterprise console. ------------------------------------------------------
# run the silent installer for linux.
./${appd_platform_installer} -q -varfile ${response_file}

# verify installation.
cd ${appd_platform_folder}/platform-admin/bin
./platform-admin.sh show-platform-admin-version

# shutdown the appdynamics platform components. ----------------------------------------------------
# stop the appdynamics enterprise console.
./platform-admin.sh stop-platform-admin

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
  echo "ExecStart=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh start-platform-admin" >> "${service_filepath}"
  echo "ExecStop=/opt/appdynamics/platform/platform-admin/bin/platform-admin.sh stop-platform-admin" >> "${service_filepath}"
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
