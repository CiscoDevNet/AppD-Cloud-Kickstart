#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install MySQL Community Server 5.7 by Oracle on CentOS Linux 7.x.
#
# The MySQL software delivers a very fast, multithreaded, multi-user, and robust SQL (Structured
# Query Language) database server. MySQL Server is intended for mission-critical, heavy-load
# production systems as well as for embedding into mass-deployed software.
#
# For more details, please visit:
#   https://dev.mysql.com/doc/refman/5.7/en/
#   https://dev.mysql.com/doc/refman/5.7/en/linux-installation-yum-repo.html
#   https://dev.mysql.com/downloads/repo/yum/
#   https://www.mysql.com/support/supportedplatforms/database.html
#   https://dev.mysql.com/doc/refman/5.7/en/socket-pluggable-authentication.html
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
mysql_yum_release="${mysql_yum_release:-80}"                            # [optional] yum repository version (defaults to '80').
mysql_server_default="${mysql_server_default:-80}"                      # [optional] mysql server version (defaults to '80').
mysql_server_release="${mysql_server_release:-57}"                      # [optional] mysql server version (defaults to '57').

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"           # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# create scripts directory (if needed). ------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos
cd ${kickstart_home}/provisioners/scripts/centos

# download mysql yum repository. -------------------------------------------------------------------
mysql_yum_binary="mysql${mysql_yum_release}-community-release-el7-5.noarch.rpm"

# download the mysql yum repository.
rm -f ${mysql_yum_binary}
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://dev.mysql.com/get/${mysql_yum_binary}

# install mysql server. ----------------------------------------------------------------------------
# install mysql yum repository.
yum -y localinstall ${mysql_yum_binary}

# enable/disable mysql subrepositories.
yum-config-manager --disable mysql${mysql_server_default}-community
yum-config-manager --enable mysql${mysql_server_release}-community

# install mysql server binaries.
#yum -y remove mariadb-libs                 # [optional] if running in the desktop.
yum -y install mysql-community-server
#yum -y install mysql-workbench-community   # [optional]

# configure mysql server. --------------------------------------------------------------------------
# start the mysql service and configure it to start at boot time.
systemctl start mysqld
systemctl enable mysqld

# check that the mysql service is running.
systemctl status mysqld

# set the root password.
mysql_server_temp_password=$(awk '/temporary password/ {print $11}' /var/log/mysqld.log)
set +x  # temporarily turn command display OFF.
mysql -u root -p${mysql_server_temp_password} --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_server_root_password}';"
set -x  # turn command display back ON.

# display configuration info and verify version. ---------------------------------------------------
set +x  # temporarily turn command display OFF.
mysqladmin -u root -p${mysql_server_root_password} version
set -x  # turn command display back ON.
