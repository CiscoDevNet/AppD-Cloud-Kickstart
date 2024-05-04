#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics EUM Server by AppDynamics.
#
# The EUM Server collects and processes beacons sent by Web browsers and Mobile applications that 
# are instrumented with AppDynamics EUM agents.
#
# For more details, please visit:
#   https://docs.appdynamics.com/latest/en/application-performance-monitoring-platform/eum-server-deployment
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
# [MANDATORY-PRESET] appdynamics platform install parameters [w/ defaults].
appd_controller_url="${appd_controller_url:-http://controller-node-01:8090}"
appd_eum_public_host="${appd_eum_public_host:-}"
appd_eum_private_host="${appd_eum_private_host:-}"

# [OPTIONAL] appdynamics platform install parameters [w/ defaults].
# appd platform install parameters.
appd_home="${appd_home:-/opt/appdynamics}"
appd_eum_server_home="${appd_eum_server_home:-eum}"
appd_eum_server_release="${appd_eum_server_release:-24.3.0.35311}"
appd_eum_server_sha256="${appd_eum_server_sha256:-9cd45afe251f05e427aafc6f7bc0c3497834a633d6bae6364b0813fc9f990d19}"
appd_platform_user_name="${appd_platform_user_name:-centos}"
appd_platform_user_group="${appd_platform_user_group:-centos}"
appd_eum_server_jvm_xms="${appd_eum_server_jvm_xms:-1024}"
appd_eum_server_jvm_xmx="${appd_eum_server_jvm_xmx:-4096}"
appd_eum_server_jdk_08="${appd_eum_server_jdk_08:-/usr/local/java/jdk180}"
appd_eum_server_jdk_17="${appd_eum_server_jdk_17:-/usr/local/java/jdk17}"
set +x  # temporarily turn command display OFF.
appd_platform_keystore_password="${appd_platform_keystore_password:-welcome1}"
appd_platform_db_password="${appd_platform_db_password:-welcome1}"
appd_platform_db_root_password="${appd_platform_db_root_password:-welcome1}"
set -x  # turn command display back ON.
appd_platform_server_host="${appd_platform_server_host:-$local_hostname}"
appd_platform_server_http_port="${appd_platform_server_http_port:-7001}"
appd_platform_server_https_port="${appd_platform_server_http_port:-7002}"


# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics EUM Server by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY-PRESET] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_controller_url="http://10.20.10.20:8090"        # controller url.
    [root]# export appd_eum_public_host="35.209.61.35"
    [root]# export appd_eum_private_host="eum-server-node"

  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_eum_server_home="eum"                           # [optional] platform home folder (defaults to 'eum').
    [root]# export appd_eum_server_release="24.3.0.35311"               # [optional] platform release (defaults to '24.3.0.35311').
                                                                        # [optional] platform sha-256 checksum (defaults to published value).
    [root]# export appd_eum_server_sha256="9cd45afe251f05e427aafc6f7bc0c3497834a633d6bae6364b0813fc9f990d19"
    [root]# export appd_platform_user_name="appd"                       # [optional] platform user name (defaults to 'appd').
    [root]# export appd_platform_user_group="appd"                      # [optional] platform group (defaults to 'appd').
    [root]# export appd_eum_server_jvm_xms=1024"                        # [optional] platform JVM XMS (defaults to '1024').
    [root]# export appd_eum_server_jvm_xmx=4096"                        # [optional] platform JVM XMX (defaults to '4096').
    [root]# export appd_platform_keystore_password="welcome1"           # [optional] platform keystore password (defaults to 'welcome1').
    [root]# export appd_platform_db_password="welcome1"                 # [optional] platform database password (defaults to 'welcome1').
    [root]# export appd_platform_db_root_password="welcome1"            # [optional] platform database root password (defaults to 'welcome1').
    [root]# export appd_platform_server_host="apm"                      # [optional] platform server hostname.
    [root]# export appd_platform_server_http_port="7001"                # [optional] platform server http port (defaults to '7001').
    [root]# export appd_platform_server_https_port="7002"               # [optional] platform server https port (defaults to '7002').


  [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
    [root]# export kickstart_home="/opt/appd-cloud-kickstart"           # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -z "$appd_controller_url" ]; then
  echo "Error: 'appd_controller_url' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_eum_public_host" ]; then
  echo "Error: 'appd_eum_public_host' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_eum_private_host" ]; then
  echo "Error: 'appd_eum_private_host' environment variable not set."
  usage
  exit 1
fi

# retrieve environment variables from controller. --------------------------------------------------

# login to controller
cookies=$(curl -s -i --user root@system:welcome1 ${appd_controller_url}/controller/auth?action=login | awk '/Set-Cookie/ {cookie = cookie $2} END {print cookie}')

# store session and auth token
jsession_id=$(echo $cookies | awk -F ';' '{print $1}')
csrf_token=$(echo $cookies | awk -F ';' '{print $2}')

echo "JSESSIONID = " $jsession_id
echo "CSRF-TOKEN = " $csrf_token

# pull down account settings from controller admin.jsp and parse out
curl -s -o output.txt -H "Cookie: ${jsession_id};${csrf_token};" -H "Accept: */*" "${appd_controller_url}/controller/restui/user/initData?${csrf_token}"
appd_events_service_url=$(cat output.txt | awk '/appdynamics.on.premise.event.service.url/{nr[NR+1]}; NR in nr' | awk -F '"' '{print $4}')

echo "appd_events_service_url = " $appd_events_service_url

appd_events_service_scheme=$(echo ${appd_events_service_url} | awk -F ':' '{print $1}')
appd_events_service_host=$(echo ${appd_events_service_url} | awk -F ':' '{print substr($2,3)}')
appd_events_service_port=$(echo ${appd_events_service_url} | awk -F ':' '{print $3}')

appd_events_service_api_key=$(cat output.txt | awk '/appdynamics.es.eum.key/{nr[NR+1]}; NR in nr' | awk -F '"' '{print $4}')

echo "appd_events_service_scheme = " $appd_events_service_scheme
echo "appd_events_service_host = " $appd_events_service_host
echo "appd_events_service_port = " $appd_events_service_port
echo "appd_events_service_api_key = " $appd_events_service_api_key

if [ -z "$appd_events_service_url" ]; then
  echo "Error: 'appd_events_service_url' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_events_service_scheme" ]; then
  echo "Error: 'appd_events_service_scheme' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_events_service_host" ]; then
  echo "Error: 'appd_events_service_host' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_events_service_port" ]; then
  echo "Error: 'appd_events_service_port' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_events_service_api_key" ]; then
  echo "Error: 'appd_events_service_api_key' environment variable not set."
  usage
  exit 1
fi


# set appdynamics platform installation variables. -------------------------------------------------
appd_platform_folder="${appd_home}/${appd_eum_server_home}"
appd_platform_installer="euem-64bit-linux-${appd_eum_server_release}.sh"

# install platform prerequisites. ------------------------------------------------------------------
# install network and ui tools.
yum -y install net-tools libaio numactl tzdata ncurses-libs

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

# create temporary download directory. -------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos/appdynamics
cd ${kickstart_home}/provisioners/scripts/centos/appdynamics

# download the appdynamics platform installer. -----------------------------------------------------
# download the installer.
rm -f ${appd_platform_installer}
curl --silent --location --remote-name https://download-files.appdynamics.com/download-file/euem-processor/${appd_eum_server_release}/${appd_platform_installer}
chmod 755 ${appd_platform_installer}

# verify the downloaded binary.
echo "${appd_eum_server_sha256} ${appd_platform_installer}" | sha256sum --check
# euem-64bit-linux-${appd_eum_server_release}.sh: OK

# create silent response file for installer. -------------------------------------------------------
response_file="appd-platform-response.varfile"

rm -f "${response_file}"
touch "${response_file}"
chmod 644 "${response_file}"

echo "sys.adminRights\$Boolean=false" >> "${response_file}"
echo "sys.languageId=en" >> "${response_file}"
echo "sys.installationDir=${appd_platform_folder}" >> "${response_file}"
echo "euem.InstallationMode=split" >> "${response_file}"
echo "euem.Host=${appd_platform_server_host}" >> "${response_file}"
echo "euem.initialHeapXms=${appd_eum_server_jvm_xms}" >> "${response_file}"
echo "euem.maximumHeapXmx=${appd_eum_server_jvm_xmx}" >> "${response_file}"
echo "mysql.dbHostName=localhost" >> "${response_file}"
echo "mysql.databasePort=3388" >> "${response_file}"
echo "mysql.dataDir=${appd_platform_folder}/data" >> "${response_file}"
set +x  # temporarily turn command display OFF.
echo "mysql.databaseRootUser=root" >> "${response_file}"
echo "mysql.rootUserPassword=${appd_platform_db_root_password}" >> "${response_file}"
echo "mysql.rootUserPasswordReEnter=${appd_platform_db_root_password}" >> "${response_file}"
echo "eumDatabasePassword=${appd_platform_db_password}" >> "${response_file}"
echo "eumDatabaseReEnterPassword=${appd_platform_db_password}" >> "${response_file}"
echo "keyStorePassword=${appd_platform_keystore_password}" >> "${response_file}"
echo "keyStorePasswordReEnter=${appd_platform_keystore_password}" >> "${response_file}"
set -x  # turn command display back ON.
echo "eventsService.isEnabled\$Boolean=true" >> "${response_file}"
echo "eventsService.serverScheme=${appd_events_service_scheme}" >> "${response_file}"
echo "eventsService.host=${appd_events_service_host}" >> "${response_file}"
echo "eventsService.port=${appd_events_service_port}" >> "${response_file}"
echo "eventsService.APIKey=${appd_events_service_api_key}" >> "${response_file}"


# install the appdynamics EUM server. ------------------------------------------------------
# run the silent installer for linux.
./${appd_platform_installer} -q -varfile ${response_file}


# provision the license.lic file for the EUM server
cd ${appd_platform_folder}/eum-processor
./bin/provision-license /tmp/license.lic

# !!!!!!!!!!!!!!!! TODO: Validate output from provision license
#EUM Account [test-eum-account-edbarberis-1593453683758] with key [a8c4dca6-8c7d-4fdd-8a1c-93cf89a9c7b4] is registered and license terms are provisioned in the EUM PROCESSOR


# set EUM properties in controller 
cookies=$(curl -s -i --user root@system:welcome1 ${appd_controller_url}/controller/auth?action=login | awk '/Set-Cookie/ {cookie = cookie $2} END {print cookie}')

jsession_id=$(echo $cookies | awk -F ';' '{print $1}')
csrf_token=$(echo $cookies | awk -F ';' '{print $2}')

echo "JSESSIONID = " $jsession_id
echo "CSRF-TOKEN = " $csrf_token

post_data_filename="post-data.json"

# 1-- set the "eum.cloud.host" property
appd_controller_conf_key="eum.cloud.host"
appd_controller_conf_value="http://${appd_eum_private_host}:7001"

rm -f "${post_data_filename}"
touch "${post_data_filename}"
chmod 644 "${post_data_filename}"
set +x  # temporarily turn command display OFF.
echo "{" >> ${post_data_filename}
echo "  \"name\": \"${appd_controller_conf_key}\"," >> ${post_data_filename}
echo "  \"value\": \"${appd_controller_conf_value}\"" >> ${post_data_filename}
echo "}" >> ${post_data_filename}
set -x  # turn command display back ON.

curl --silent --request POST --data @${post_data_filename} -H "Cookie: ${jsession_id};${csrf_token};" -H "Accept: */*" -H "Content-Type: application/json;charset=UTF-8" "${appd_controller_url}/controller/restui/admin/configuration/set?${csrf_token}"


# 2-- set the "eum.beacon.host" property
appd_controller_conf_key="eum.beacon.host"
appd_controller_conf_value="${appd_eum_public_host}:7001"

rm -f "${post_data_filename}"
touch "${post_data_filename}"
chmod 644 "${post_data_filename}"
set +x  # temporarily turn command display OFF.
echo "{" >> ${post_data_filename}
echo "  \"name\": \"${appd_controller_conf_key}\"," >> ${post_data_filename}
echo "  \"value\": \"${appd_controller_conf_value}\"" >> ${post_data_filename}
echo "}" >> ${post_data_filename}
set -x  # turn command display back ON.

curl --silent --request POST --data @${post_data_filename} -H "Cookie: ${jsession_id};${csrf_token};" -H "Accept: */*" -H "Content-Type: application/json;charset=UTF-8" "${appd_controller_url}/controller/restui/admin/configuration/set?${csrf_token}"


# 3-- set the "eum.beacon.https.host" property
appd_controller_conf_key="eum.beacon.https.host"
appd_controller_conf_value="https://${appd_eum_public_host}:7002"

rm -f "${post_data_filename}"
touch "${post_data_filename}"
chmod 644 "${post_data_filename}"
set +x  # temporarily turn command display OFF.
echo "{" >> ${post_data_filename}
echo "  \"name\": \"${appd_controller_conf_key}\"," >> ${post_data_filename}
echo "  \"value\": \"${appd_controller_conf_value}\"" >> ${post_data_filename}
echo "}" >> ${post_data_filename}
set -x  # turn command display back ON.

curl --silent --request POST --data @${post_data_filename} -H "Cookie: ${jsession_id};${csrf_token};" -H "Accept: */*" -H "Content-Type: application/json;charset=UTF-8" "${appd_controller_url}/controller/restui/admin/configuration/set?${csrf_token}"


# 4-- set the "eum.mobile.screenshot.host" property
appd_controller_conf_key="eum.mobile.screenshot.host"
appd_controller_conf_value="${appd_eum_private_host}:7001"

rm -f "${post_data_filename}"
touch "${post_data_filename}"
chmod 644 "${post_data_filename}"
set +x  # temporarily turn command display OFF.
echo "{" >> ${post_data_filename}
echo "  \"name\": \"${appd_controller_conf_key}\"," >> ${post_data_filename}
echo "  \"value\": \"${appd_controller_conf_value}\"" >> ${post_data_filename}
echo "}" >> ${post_data_filename}
set -x  # turn command display back ON.

curl --silent --request POST --data @${post_data_filename} -H "Cookie: ${jsession_id};${csrf_token};" -H "Accept: */*" -H "Content-Type: application/json;charset=UTF-8" "${appd_controller_url}/controller/restui/admin/configuration/set?${csrf_token}"


# 5-- set the "eum.es.host" property
appd_controller_conf_key="eum.es.host"
appd_controller_conf_value="${appd_events_service_host}:${appd_events_service_port}"

rm -f "${post_data_filename}"
touch "${post_data_filename}"
chmod 644 "${post_data_filename}"
set +x  # temporarily turn command display OFF.
echo "{" >> ${post_data_filename}
echo "  \"name\": \"${appd_controller_conf_key}\"," >> ${post_data_filename}
echo "  \"value\": \"${appd_controller_conf_value}\"" >> ${post_data_filename}
echo "}" >> ${post_data_filename}
set -x  # turn command display back ON.

curl --silent --request POST --data @${post_data_filename} -H "Cookie: ${jsession_id};${csrf_token};" -H "Accept: */*" -H "Content-Type: application/json;charset=UTF-8" "${appd_controller_url}/controller/restui/admin/configuration/set?${csrf_token}"


cd ${appd_platform_folder}/eum-processor
sudo pkill -f com.appdynamics.eumcloud.EUMProcessorServer
sudo pkill -f com.appdynamics.eumcloud.OnPremLicenseProvisionCommand
sleep 3s
rm -f "${appd_platform_folder}/eum-processor/pid.txt"



# create the start script for the service
eum_start_script="${appd_platform_folder}/eum-processor/start_eum.sh"

rm -f "${eum_start_script}"
touch "${eum_start_script}"
chmod 744 "${eum_start_script}"

echo "#!/bin/sh -eux" >> "${eum_start_script}"
echo "cd "${appd_platform_folder}"/eum-processor/" >> "${eum_start_script}"
echo "bin/eum.sh start" >> "${eum_start_script}"
echo "" >> "${eum_start_script}"


# create the stop script for the service
eum_stop_script="${appd_platform_folder}/eum-processor/stop_eum.sh"

rm -f "${eum_stop_script}"
touch "${eum_stop_script}"
chmod 744 "${eum_stop_script}"

echo "#!/bin/sh -eux" >> "${eum_stop_script}"
echo "cd "${appd_platform_folder}"/eum-processor/" >> "${eum_stop_script}"
echo "bin/eum.sh stop" >> "${eum_stop_script}"
echo "" >> "${eum_stop_script}"


# configure the appdynamics EUM Server MySQL DB as a service. ---------------------------------------
systemd_dir="/etc/systemd/system"
appd_eum_db_service="appdynamics-eum-db.service"
service_filepath="${systemd_dir}/${appd_eum_db_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"
  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The AppDynamics EUM MySQL DB." >> "${service_filepath}"
  echo "Wants=network-online.target" >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "Type=forking" >> "${service_filepath}"

  if [ "$appd_platform_user_name" != "root" ]; then
    echo "User=${appd_platform_user_name}" >> "${service_filepath}"
    echo "Group=${appd_platform_user_group}" >> "${service_filepath}"
  fi

  echo "Environment=JAVA_HOME=${appd_eum_server_jdk_08}" >> "${service_filepath}"
  echo "WorkingDirectory=${appd_platform_folder}/orcha/orcha-manager/bin/" >> "${service_filepath}"
  echo "ExecStart=${appd_platform_folder}/orcha/orcha-manager/bin/orcha-manager -d mysql.groovy -p ${appd_platform_folder}/orcha/playbooks/mysql-orcha/start-mysql.orcha -o ${appd_platform_folder}/orcha/orcha-manager/conf/orcha.properties -c local" >> "${service_filepath}"
  echo "ExecStop=${appd_platform_folder}/orcha/orcha-manager/bin/orcha-manager -d mysql.groovy -p ${appd_platform_folder}/orcha/playbooks/mysql-orcha/stop-mysql.orcha -o ${appd_platform_folder}/orcha/orcha-manager/conf/orcha.properties -c local" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

# enable the EUM MySQL DB to start at boot time.
systemctl enable "${appd_eum_db_service}"
systemctl is-enabled "${appd_eum_db_service}"

# stop eum mysql db
#${appd_platform_folder}/orcha/orcha-manager/bin/orcha-manager -d mysql.groovy -p ${appd_platform_folder}/orcha/playbooks/mysql-orcha/stop-mysql.orcha -o ${appd_platform_folder}/orcha/orcha-manager/conf/orcha.properties -c local
pkill -f mysql


# configure the appdynamics EUM Server as a service. ---------------------------------------
systemd_dir="/etc/systemd/system"
appd_eum_server_service="appdynamics-eum-server.service"
service_filepath="${systemd_dir}/${appd_eum_server_service}"

# create systemd service file.
if [ -d "$systemd_dir" ]; then
  rm -f "${service_filepath}"
  touch "${service_filepath}"
  chmod 644 "${service_filepath}"

  echo "[Unit]" >> "${service_filepath}"
  echo "Description=The AppDynamics EUM Server." >> "${service_filepath}"
  echo "After=network.target remote-fs.target nss-lookup.target appdynamics-eum-db.service" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Service]" >> "${service_filepath}"
  echo "Type=forking" >> "${service_filepath}"
  echo "BindsTo=appdynamics-eum-db.service" >> "${service_filepath}"

  if [ "$appd_platform_user_name" != "root" ]; then
    echo "User=${appd_platform_user_name}" >> "${service_filepath}"
    echo "Group=${appd_platform_user_group}" >> "${service_filepath}"
  fi

  echo "Environment=JAVA_HOME=${appd_platform_folder}/jre" >> "${service_filepath}"
  echo "WorkingDirectory=${appd_platform_folder}/eum-processor/" >> "${service_filepath}"
  echo "ExecStart=${appd_platform_folder}/eum-processor/start_eum.sh" >> "${service_filepath}"
  echo "ExecStop=${appd_platform_folder}/eum-processor/stop_eum.sh" >> "${service_filepath}"
  echo "" >> "${service_filepath}"
  echo "[Install]" >> "${service_filepath}"
  echo "WantedBy=multi-user.target" >> "${service_filepath}"
fi

# reload systemd manager configuration.
systemctl daemon-reload

# enable the EUM Server to start at boot time.
systemctl enable "${appd_eum_server_service}"
systemctl is-enabled "${appd_eum_server_service}"


# change ownership to platform user name and group. ------------------------------------------------
if [ "$appd_platform_user_name" != "root" ]; then
  cd ${appd_home}
  chown -R ${appd_platform_user_name}:${appd_platform_user_group} .
fi


# start the service.
systemctl start "${appd_eum_db_service}"

# check current status.
systemctl status "${appd_eum_db_service}"

sleep 3s

# start the service.
systemctl start "${appd_eum_server_service}"

# check current status.
systemctl status "${appd_eum_server_service}"

#sleep 8s

# verify installation.
#ping_success=$(curl "http://${appd_eum_public_host}:7001/eumaggregator/ping")
#if [ "ping" = "${ping_success}" ]; then 
#   echo "EUM Server is running ..."
#else
#   echo "EUM Server is not responding ..."
#fi
