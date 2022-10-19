#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Initialize PoV Playbook1 Supercar Trader application database schema.
#
# Supercar Trader is a simple Struts application that provides an online store front with
# intentional performance and code issues. This makes it ideal for APM workshops and demos.
#
# The application uses a MySQL 5.7 back-end (recommended), and requires a default "supercars"
# schema, which this script imports. MySQL must be running on the same host as the application.
#
# For more details, please visit:
#   https://povplaybook.appdpartnerlabs.net/
#   https://povplaybook.appdpartnerlabs.net/30_app_srvr_setup.html#initialize-application-database
#   https://povplaybook.appdpartnerlabs.net/40_java_lab/3_lab-exercise-.html
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] mysql server install parameters [w/ defaults].
# pov playbook1 lab artifacts directory (defaults to '/opt/appdynamics/lab-artifacts').
pov_playbook1_lab_artifacts_dir="${pov_playbook1_lab_artifacts_dir:-/opt/appdynamics/lab-artifacts}"
set +x  # temporarily turn command display OFF.
mysql_server_root_password="${mysql_server_root_password:-Welcome1!}"   # [optional] root password (defaults to 'Welcome1!').
set -x  # turn command display back ON.
mysql_server_release="${mysql_server_release:-mysql-5.7}"               # [optional] mysql server version (defaults to 'mysql-5.7').

# initialize pov playbook1 supercar trader database schema from source. ----------------------------
# check that the mysql service is running.
mysql_server_is_running=$(pgrep mysqld | wc -l)
if [ "${mysql_server_is_running}" -ne 1 ]; then
  systemctl start mysqld
fi

# change to the lab artifacts supercar trader sql scripts directory.
cd ${pov_playbook1_lab_artifacts_dir}/db-scripts

# upgrade supercar trader sql script for mysql server 8.0 by commenting out the 'SET GLOBAL' statements.
if [ "$mysql_server_release" == "mysql-8.0" ]; then
  # save a copy of the original file.
  sql_command_file="mysql-01.sql"
  cp -p ${sql_command_file} ${sql_command_file}.orig

  # comment out 'query_cache_size' and 'query_cache_type' since they don't exist in mysql server 8.0.
  #   -- SET GLOBAL query_cache_size = 0;
  #   -- SET GLOBAL query_cache_type = 0;

  # add sql comment string.
  sql_statement_search_string=".*SET GLOBAL.*"
  sed -i "s/^${sql_statement_search_string}/-- &/g" ${sql_command_file}
fi

# these 3 scripts must be run in order.
set +x  # temporarily turn command display OFF.
mysql -u root -p${mysql_server_root_password} < mysql-01.sql
mysql -u root -p${mysql_server_root_password} < mysql-02.sql
mysql -u root -p${mysql_server_root_password} < mysql-03.sql
set -x  # turn command display back ON.

# verify schema initialization.
set +x  # temporarily turn command display OFF.
mysql -u root -p${mysql_server_root_password} -e "show tables;" supercars
set -x  # turn command display back ON.
echo "PoV Playbook1 Supercar Trader application database schema initialization complete."
