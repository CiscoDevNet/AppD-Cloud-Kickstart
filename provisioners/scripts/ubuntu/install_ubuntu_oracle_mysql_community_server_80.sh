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
#   https://www.mysql.com/support/supportedplatforms/database.html
#   https://dev.mysql.com/doc/refman/8.0/en/socket-pluggable-authentication.html
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
mysql_apt_repo_release="${mysql_apt_repo_release:-0.8.33-1}"            # [optional] apt repository version (defaults to '0.8.33-1').
mysql_server_release="${mysql_server_release:-mysql-8.0}"               # [optional] mysql server version (defaults to 'mysql-8.0').
                                                                        # [optional] mysql apt repository md5 checksum (defaults to published value).
mysql_apt_checksum="${mysql_apt_checksum:-e1716b19b84b92f32e94dfd34892322c}"
mysql_enable_secure_access="${mysql_enable_secure_access:-true}"        # [optional] enable secure access for mysql server (defaults to 'true').

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"           # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# validate ubuntu release version. -----------------------------------------------------------------
# check for supported ubuntu release.
ubuntu_release=$(lsb_release -rs)

if [ -n "$ubuntu_release" ]; then
  case $ubuntu_release in
      20.04|22.04|24.04|24.10)
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
mysql_apt_pgpkey_file="A8D3785C.pub"
mysql_apt_sig_file="${mysql_apt_binary}.asc"

# download the mysql apt repository.
rm -f ${mysql_apt_binary}
wget --no-verbose --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://dev.mysql.com/get/${mysql_apt_binary}

# verify the downloaded binary using the md5 checksum.
echo "${mysql_apt_checksum} ${mysql_apt_binary}" | md5sum --check -
# mysql-apt-config_${mysql_apt_repo_release}_all.deb: OK

# download the mysql apt pgp signature.
rm -f ${mysql_apt_sig_file}
curl --silent --location "https://dev.mysql.com/downloads/gpg/?file=${mysql_apt_binary}&p=37" --output ${mysql_apt_sig_file}

# create pgp public key file.
rm -f ${mysql_apt_pgpkey_file}
cat <<EOF > ${mysql_apt_pgpkey_file}
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: SKS 1.1.6
Comment: Hostname: pgp.mit.edu

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
cAZUlaj3id3TxquAlud4lWDz
=h5nH
-----END PGP PUBLIC KEY BLOCK-----
EOF

# import the mysql apt repository public key.
set +e  # temporarily turn 'exit pipeline on non-zero return status' OFF.
gpg --import ${mysql_apt_pgpkey_file}
set -e  # turn 'exit pipeline on non-zero return status' back ON.

# verify the downloaded binary using the pgp signature.
gpg --verify ${mysql_apt_sig_file} ${mysql_apt_binary}

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
set -x  # turn command display back ON.

# verify 'root' user authentication method.
set +x  # temporarily turn command display OFF.
mysql -u root -p${mysql_server_root_password} -e "SELECT user, plugin FROM mysql.user WHERE user IN ('root')\G;"
set -x  # turn command display back ON.

# improve mysql server installation security. ------------------------------------------------------
# if secure access is enabled, remove anonymous users, disallow remote 'root' logins, and remove test database.
if [ "$mysql_enable_secure_access" = "true" ]; then
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

# display installed plugins.
set +x  # temporarily turn command display OFF.
mysql -u root -p${mysql_server_root_password} -e "SELECT PLUGIN_NAME, PLUGIN_STATUS FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_STATUS LIKE '%ACTIVE%'\G;"
set -x    # turn command display back ON.
