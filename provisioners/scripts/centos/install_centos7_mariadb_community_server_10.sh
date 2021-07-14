#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install MariaDB Community Server 10.6 by MariaDB on CentOS Linux 7.x.
#
# MariaDB Server is one of the most popular open source relational databases. It’s made by the
# original developers of MySQL and guaranteed to stay open source. It is part of most cloud
# offerings and the default in most Linux distributions.
#
# It is built upon the values of performance, stability, and openness, and MariaDB Foundation
# ensures contributions will be accepted on technical merit. Recent new functionality includes
# advanced clustering with Galera Cluster 4, compatibility features with Oracle Database and
# Temporal Data Tables, allowing one to query the data as it stood at any point in the past.
#
# For more details, please visit:
#   https://mariadb.com/docs/features/mariadb-community-server/#mariadb-community-server
#   https://mariadb.com/downloads/
#   https://mariadb.org/
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] mariadb server install parameters [w/ defaults].
set +x  # temporarily turn command display OFF.
mariadb_server_root_password="${mariadb_server_root_password:-Password1234!}"   # [optional] root password (defaults to 'Password1234!').
set -x  # turn command display back ON.

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"                   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# create scripts directory (if needed). ------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos
cd ${kickstart_home}/provisioners/scripts/centos

# configure mariadb yum repository. ----------------------------------------------------------------
rm -f mariadb_repo_setup
wget --no-verbose https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod 755 ./mariadb_repo_setup
./mariadb_repo_setup

# install mariadb server. --------------------------------------------------------------------------
# install mariadb server binaries.
yum -y install MariaDB-server

# configure mariadb server. ------------------------------------------------------------------------
# start the mariadb service and configure it to start at boot time.
systemctl enable --now mariadb

# check that the mariadb service is running.
systemctl is-enabled mariadb
systemctl status mariadb

# secure the mariadb installation and set the root password. ---------------------------------------
# run the mariadb secure install command with the following pre-set answers:
#   Enter current password for root (enter for none):
#   Switch to unix_socket authentication [Y/n] n
#   Change the root password? [Y/n] Y
#   New password:
#   Re-enter new password:
#   Remove anonymous users? [Y/n] Y
#   Disallow root login remotely? [Y/n] Y
#   Remove test database and access to it? [Y/n] Y
#   Reload privilege tables now? [Y/n] Y
set +x    # temporarily turn command display OFF.
mariadb_secure_install_cmd=$(printf "mariadb-secure-installation <<< \$\'\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n%s\\\\n\'\n" n Y ${mariadb_server_root_password} ${mariadb_server_root_password} Y Y Y Y)
eval ${mariadb_secure_install_cmd}
set -x    # turn command display back ON.

# display configuration info and verify version. ---------------------------------------------------
set +x  # temporarily turn command display OFF.
mariadb-admin -u root -p${mariadb_server_root_password} version
set -x  # turn command display back ON.
