#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install TeaStore microservice application on Docker.
#
# The TeaStore is a microservice reference and test application to be used in benchmarks and
# tests. The TeaStore emulates a basic web store for automatically generated tea and tea supplies.
# As it is primarily a test application, it features UI elements for database generation and
# service resetting in addition to the store itself.
#
# The TeaStore's persistence services use a MySQL/MariaDB database running in a container. The
# store automatically creates the required tables and resets them using the web UI. The following
# is a summary of the default database settings:
#
#   Default Host:      localhost
#   Default Port:      3306
#   Database name:     teadb
#   Database user:     teauser
#   Database password: teapassword
#
# For more details, please visit:
#   https://github.com/DescartesResearch/TeaStore
#   https://github.com/DescartesResearch/TeaStore/wiki/Getting-Started
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] teastore application install parameters [w/ defaults].
user_name="${user_name:-centos}"                    # [optional] user name (defaults to 'centos').
user_group="${user_group:-centos}"                  # [optional] user group (defaults to 'centos').

# import teastore application project from github.com. ---------------------------------------------
# create teastore application project parent folder.
mkdir -p /usr/local/src
cd /usr/local/src

# download teastore application project from github.com.
rm -Rf ./TeaStore
git clone https://github.com/DescartesResearch/TeaStore.git
cd /usr/local/src/TeaStore
git fetch origin

# set current date for temporary filename. ---------------------------------------------------------
curdate=$(date +"%Y-%m-%d.%H-%M-%S")

# edit the default docker-compose configuration to 'always' restart containers. --------------------
docker_compose_file="docker-compose_default.yaml"
cd /usr/local/src/TeaStore/examples/docker
cp -p ${docker_compose_file} ${docker_compose_file}.orig
awk '/^    image: descartesresearch/ {$0=$0"\n    restart: always"} 1' ${docker_compose_file} > ${docker_compose_file}.${curdate}
mv ${docker_compose_file}.${curdate} ${docker_compose_file}

# change file and group ownership. -----------------------------------------------------------------
cd /usr/local/src/TeaStore
chown -R ${user_name}:${user_group} .

# deploy teastore container services. --------------------------------------------------------------
runuser -c "docker-compose -f /usr/local/src/TeaStore/examples/docker/${docker_compose_file} up -d" - ${user_name}
