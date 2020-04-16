#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Initialize Supercar Trader application database schema.
#
# Supercar Trader is a simple Struts application that provides an online store front with
# intentional performance and code issues. This makes it ideal for APM workshops and demos.
#
# The application uses a MySQL 5.7 back-end (recommended), and requires a default "supercars"
# schema, which this script imports. MySQL must be running on the same host as the application.
#
# For more details, please visit:
#   https://github.com/Appdynamics/DevNet-Labs/tree/master/applications/Supercar-Trader
#   https://github.com/Appdynamics/DevNet-Labs
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] mysql server install parameters [w/ defaults].
set +x  # temporarily turn command display OFF.
mysql_server_root_password="${mysql_server_root_password:-Welcome1!}"   # [optional] root password (defaults to 'Welcome1!').
set -x  # turn command display back ON.

# import devnet labs project from github.com. ------------------------------------------------------
# create devnet labs project parent folder.
mkdir -p /usr/local/src
cd /usr/local/src

# download devnet labs project from github.com.
rm -Rf ./DevNet-Labs
git clone https://github.com/Appdynamics/DevNet-Labs.git
cd DevNet-Labs
git fetch origin

# initialize supercar trader database schema from source. ------------------------------------------
# check that the mysql service is running.
mysql_server_is_running=$(pgrep mysqld | wc -l)
if [ "${mysql_server_is_running}" -ne 1 ]; then
  systemctl start mysqld
fi

# change to the supercar trader sql scripts directory.
cd applications/Supercar-Trader/src/main/resources/db

# these 3 scripts must be run in order.
set +x  # temporarily turn command display OFF.
mysql -u root -p${mysql_server_root_password} < mysql-01.sql
mysql -u root -p${mysql_server_root_password} < mysql-02.sql
mysql -u root -p${mysql_server_root_password} < mysql-03.sql

# verify schema initialization.
mysql -u root -p${mysql_server_root_password} -e "show tables;" supercars
set -x  # turn command display back ON.
echo "Supercar Trader application database schema initialization complete."
