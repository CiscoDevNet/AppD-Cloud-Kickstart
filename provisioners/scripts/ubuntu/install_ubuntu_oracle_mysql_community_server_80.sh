#!/bin/bash -eux
#---------------------------------------------------------------------------------------------------
# Install MySQL Community Server 8.0 by Oracle on Ubuntu Linux.
#
# The MySQL software delivers a very fast, multithreaded, multi-user, and robust SQL (Structured
# Query Language) database server. MySQL Server is intended for mission-critical, heavy-load
# production systems as well as for embedding into mass-deployed software.
#
# For more details, please visit:
#   https://dev.mysql.com/doc/refman/8.0/en/
#   https://dev.mysql.com/doc/refman/8.0/en/linux-installation-apt-repo.html
#   https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/
#   https://dev.mysql.com/downloads/repo/apt/
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] mysql server install parameters [w/ defaults].
set +x  # temporarily turn command display OFF.
mysql_server_root_password="${mysql_server_root_password:-Welcome1!}"   # [optional] root password (defaults to 'Welcome1!').
set -x  # turn command display back ON.
mysql_apt_repo_release="${mysql_apt_repo_release:-0.8.23-1}"            # [optional] apt repository version (defaults to '0.8.23-1').
mysql_server_release="${mysql_server_release:-mysql-8.0}"               # [optional] mysql server version (defaults to 'mysql-8.0').
mysql_enable_secure_access="${mysql_enable_secure_access:-true}"        # [optional] enable secure access for mysql server (defaults to 'true').

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"           # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# validate ubuntu release version. -----------------------------------------------------------------
# check for supported ubuntu release.
ubuntu_release=$(lsb_release -rs)

if [ -n "$ubuntu_release" ]; then
  case $ubuntu_release in
      18.04|20.04|22.04)
        ;;
      *)
        echo "Error: MySQL Community Server 8.0 NOT supported on Ubuntu release: '$(lsb_release -ds)'."
        exit 1
        ;;
  esac
fi

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# create scripts directory (if needed). ------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/ubuntu
cd ${kickstart_home}/provisioners/scripts/ubuntu

# download mysql apt repository. -------------------------------------------------------------------
mysql_apt_binary="mysql-apt-config_${mysql_apt_repo_release}_all.deb"

# download the mysql apt repository.
rm -f ${mysql_apt_binary}
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://dev.mysql.com/get/${mysql_apt_binary}

# install mysql server. ----------------------------------------------------------------------------
# install mysql apt repository.
export DEBIAN_FRONTEND=noninteractive
dpkg -i ${mysql_apt_binary}
debconf-show mysql-apt-config

# configure mysql server product version.
debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-product select Ok"
debconf-set-selections <<< "mysql-apt-config mysql-apt-config/select-server select ${mysql_server_release}"
debconf-show mysql-apt-config

# reconfigure the mysql server package to use the specified release.
dpkg-reconfigure mysql-apt-config

# update the apt repository package indexes.
apt-get update

# install mysql server binaries.
apt-get -y install mysql-server

# verify mysql server installation
mysql --version
mysqladmin --version
mysqladmin -u root version

# configure mysql server. --------------------------------------------------------------------------
# start the mysql service and configure it to start at boot time.
#####systemctl start mysql
systemctl enable mysql
systemctl is-enabled mysql

# check that the mysql service is running.
systemctl status mysql

# create mysql server 'root' user password. --------------------------------------------------------
# set the 'root' user password and change authentication method to 'mysql_native_password'.
set +x  # temporarily turn command display OFF.
mysql_cmd="mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${mysql_server_root_password}';\""
#echo "mysql_cmd: \"${mysql_cmd}\""
eval ${mysql_cmd}
set -x    # turn command display back ON.

# verify 'root' user authentication method.
set +x  # temporarily turn command display OFF.
mysql -u root -p${mysql_server_root_password} -e "SELECT user, plugin FROM mysql.user WHERE user IN ('root')\G;"
set -x    # turn command display back ON.

# improve mysql server installation security. ------------------------------------------------------
# if secure access is enabled, remove anonymous users, disallow remote 'root' logins, and remove test database.
if [ "$mysql_enable_secure_access" == "true" ]; then
  # run the mysql secure install command with the following pre-set answers using the 'here string' (<<<) defined below:
  #   Would you like to setup VALIDATE PASSWORD component? Press y|Y for Yes, any other key for No: Y
  #   There are three levels of password validation policy: Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 2
  #   Change the password for root ? ((Press y|Y for Yes, any other key for No) : N
  #   Remove anonymous users? (Press y|Y for Yes, any other key for No) : Y
  #   Disallow root login remotely? (Press y|Y for Yes, any other key for No) : Y
  #   Remove test database and access to it? (Press y|Y for Yes, any other key for No) : Y
  #   Reload privilege tables now? (Press y|Y for Yes, any other key for No) : Y
  set +x  # temporarily turn command display OFF.
  mysql_secure_install_cmd=$(printf "mysql_secure_installation -u root -p%s <<< \$\'%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" ${mysql_server_root_password} Y 2 N Y Y Y Y)
  #echo "mysql_secure_install_cmd: \"${mysql_secure_install_cmd}\""
  eval ${mysql_secure_install_cmd}
  set -x    # turn command display back ON.

  # for secure access, change the 'root' user authentication method back to 'auth_socket'.
  set +x  # temporarily turn command display OFF.
  mysql -u root -p${mysql_server_root_password} -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH auth_socket;"
  mysql -u root -p${mysql_server_root_password} -e "SELECT user, plugin FROM mysql.user WHERE user IN ('root')\G;"
  set -x    # turn command display back ON.
else
  # run the mysql secure install command with the following pre-set answers using the 'here string' (<<<) defined below:
  #   Would you like to setup VALIDATE PASSWORD component? Press y|Y for Yes, any other key for No: Y
  #   There are three levels of password validation policy: Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 2
  #   Change the password for root ? ((Press y|Y for Yes, any other key for No) : N
  #   Remove anonymous users? (Press y|Y for Yes, any other key for No) : N
  #   Disallow root login remotely? (Press y|Y for Yes, any other key for No) : N
  #   Remove test database and access to it? (Press y|Y for Yes, any other key for No) : N
  #   Reload privilege tables now? (Press y|Y for Yes, any other key for No) : Y
  set +x  # temporarily turn command display OFF.
  mysql_secure_install_cmd=$(printf "mysql_secure_installation -u root -p%s <<< \$\'%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" ${mysql_server_root_password} Y 2 N N N N Y)
  #echo "mysql_secure_install_cmd: \"${mysql_secure_install_cmd}\""
  eval ${mysql_secure_install_cmd}
  set -x    # turn command display back ON.
fi

# display configuration info and verify version. ---------------------------------------------------
set +x  # temporarily turn command display OFF.
mysqladmin -u root -p${mysql_server_root_password} version
set -x  # turn command display back ON.
