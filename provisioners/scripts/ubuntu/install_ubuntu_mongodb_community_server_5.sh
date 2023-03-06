#!/bin/bash -eux
#---------------------------------------------------------------------------------------------------
# Install MongoDB Community Server 5.0 on Ubuntu Linux.
#
# MongoDB is a document database designed for ease of development and scaling. It is
# source-available, cross-platform, and classified as a NoSQL database program, MongoDB uses
# JSON-like documents with optional schemas.
#
# For more details, please visit:
#   https://www.mongodb.com/docs/manual/introduction/
#   https://www.mongodb.com/try/download/community/
#   https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] mongodb community server install parameters [w/ defaults].
user_name="${user_name:-ubuntu}"                                            # [optional] user name for testing.
user_group="${user_group:-ubuntu}"                                          # [optional] user login group for testing.
mongodb_server_admin_username="${mongodb_server_admin_username:-userAdmin}" # [optional] MongoDB admin username (defaults to 'userAdmin').
set +x  # temporarily turn command display OFF.
mongodb_server_admin_password="${mongodb_server_admin_password:-welcome1}"  # [optional] admin password (defaults to 'welcome1').
set -x  # turn command display back ON.
mongodb_enable_access_control="${mongodb_enable_access_control:-false}"     # [optional] enable access control for mongodb (defaults to 'false').

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"               # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# validate ubuntu release version. -----------------------------------------------------------------
# check for supported ubuntu release.
ubuntu_release=$(lsb_release -rs)

if [ -n "$ubuntu_release" ]; then
  case $ubuntu_release in
      16.04|18.04|20.04)
        ;;
      *)
        echo "Error: MongoDB NOT supported on Ubuntu release: '$(lsb_release -ds)'."
        exit 1
        ;;
  esac
fi

# update the apt repository package indexes. -------------------------------------------------------
apt-get update

# install tools needed to install mongodb. ---------------------------------------------------------
apt-get -y install gnupg

# prepare the mongodb package for installation. ----------------------------------------------------
# import the gpg key.
# NOTE: when adding the repository that is provided by mongodb, because of ubuntu security
#       restrictions, you cannot just add a repository. you also need to include the gpg key and
#       import it as a trusted key on the local operating system.
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -

# create a list file for mongodb.
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

# install the mongodb database. --------------------------------------------------------------------
apt-get update
apt-get -y install mongodb-org

# configure mongodb community server service. ------------------------------------------------------
# reload systemd manager configuration.
systemctl daemon-reload

# start the mongodb service and configure it to start at boot time.
systemctl start mongod
systemctl enable mongod
systemctl is-enabled mongod
sleep 10

# check that the mongodb service is running.
systemctl status mongod

# verify installation. -----------------------------------------------------------------------------
# set mongodb shell environment variables.
PATH=/usr/bin:$PATH
export PATH

# verify mongodb version.
mongo --version

# verify mongodb shell version.
mongosh --version

# create mongodb user admin (conditional). ---------------------------------------------------------
if [ "$mongodb_enable_access_control" = "true" ]; then
  # create scripts directory (if needed).
  mkdir -p ${kickstart_home}/provisioners/scripts/centos/mongodb
  cd ${kickstart_home}/provisioners/scripts/centos/mongodb

  # generate the create mongodb admin user script.
  rm -f createMongoDBAdminUser.js

  cat <<EOF > createMongoDBAdminUser.js
db = connect("mongodb://localhost/admin");
db.createUser(
  {
    user: "${mongodb_server_admin_username}",
    pwd: "${mongodb_server_admin_password}",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  }
)
EOF

  # create the mongodb admin user.
  runuser -c "mongosh --file ${kickstart_home}/provisioners/scripts/centos/mongodb/createMongoDBAdminUser.js" - ${user_name}
fi

# perform general mongodb housekeeping tasks. ------------------------------------------------------
# disable the mongodb free monitoring solution.
runuser -c "mongosh --quiet --eval \"db.disableFreeMonitoring()\"" - ${user_name}

# shutdown the mongodb database. -------------------------------------------------------------------
systemctl stop mongod
#runuser -c "mongosh --quiet --eval \"db.adminCommand( { shutdown: 1 } )\"" - ${user_name}

# configure the mongodb service for access control (conditional). ----------------------------------
if [ "$mongodb_enable_access_control" = "true" ]; then
  mongod_service_file="mongod.conf"
  cd /etc
  cp -p ${mongod_service_file} ${mongod_service_file}.orig

  # define stream editor search strings.
  mongod_config_search="#security:"

  # define stream editor mongodb service config substitution strings.
  mongod_config_line_01="# security for access control."
  mongod_config_line_02="security:"
  mongod_config_line_03="  authorization: enabled"

  # insert mongodb security config lines before this comment: '#security:'.
  sed -i -e "s/${mongod_config_search}/${mongod_config_line_01}\n${mongod_config_search}/g" ${mongod_service_file}
  sed -i -e "s/${mongod_config_search}/${mongod_config_line_02}\n${mongod_config_search}/g" ${mongod_service_file}
  sed -i -e "s/${mongod_config_search}/${mongod_config_line_03}\n${mongod_config_search}/g" ${mongod_service_file}

  # delete original security element.
  sed -i -e "/${mongod_config_search}/d" ${mongod_service_file}

  # validate new mongodb service file.
  cat ${mongod_service_file}
fi

# restart the mongodb service with the new configuration. ------------------------------------------
# start the mongodb service.
systemctl start mongod
sleep 10

# check that the mongodb service is running.
systemctl status mongod

# verify completed mongodb database configuration. -------------------------------------------------
# list mongodb users.
if [ "$mongodb_enable_access_control" = "true" ]; then
  echo "mongosh mongodb://localhost/admin --eval \"db.system.users.find()\" --authenticationDatabase \"admin\" -u \"${mongodb_server_admin_username}\" -p \"########\""
  set +x  # temporarily turn command display OFF.
  runuser -c "mongosh mongodb://localhost/admin --eval \"db.system.users.find()\" --authenticationDatabase \"admin\" -u \"${mongodb_server_admin_username}\" -p \"${mongodb_server_admin_password}\"" - ${user_name}
  set -x  # turn command display back ON.
else
  runuser -c "mongosh --eval \"db.system.users.find()\"" - ${user_name}
fi

# list mongodb installed databases.
if [ "$mongodb_enable_access_control" = "true" ]; then
  echo "mongosh --eval \"db.adminCommand( { listDatabases: 1, nameOnly: true} )\" --authenticationDatabase \"admin\" -u \"${mongodb_server_admin_username}\" -p \"########\""
  set +x  # temporarily turn command display OFF.
  runuser -c "mongosh --eval \"db.adminCommand( { listDatabases: 1, nameOnly: true} )\" --authenticationDatabase \"admin\" -u \"${mongodb_server_admin_username}\" -p \"${mongodb_server_admin_password}\"" - ${user_name}
  set -x  # turn command display back ON.
else
  runuser -c "mongosh --eval \"db.adminCommand( { listDatabases: 1, nameOnly: true} )\"" - ${user_name}
fi
