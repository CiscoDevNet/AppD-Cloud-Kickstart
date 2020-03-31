#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Cisco Workload Optimization Manager (CWOM) by Turbonomic.
#
# Cisco Workload Optimization Manager (CWOM) is a server application which allows you to assign
# virtual management services running on your network to be CWOM targets. CWOM discovers the
# devices each target manages and then performs analysis, anticipates risks to performance or
# efficiency, and recommends actions you can take to avoid problems before they occur.
#
# To keep your infrastructure in the desired state, CWOM performs Intelligent Workload Management.
# This is an ongoing process that solves the problem of assuring application performance while
# simultaneously achieving the most efficient use of resources that is possible.
#
# For more details, please visit:
#   https://www.cisco.com/c/en/us/products/servers-unified-computing/workload-optimization-manager/index.html
#   https://www.cisco.com/c/en/us/support/servers-unified-computing/workload-optimization-manager/tsd-products-support-series-home.html
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# [OPTIONAL] cwom platform install parameters [w/ defaults].
# cwom platform install parameters.
cwom_platform_release="${cwom_platform_release:-2.3.11}"            # [optional] platform release (defaults to '2.3.11').

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"       # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').

# set cwom platform installation variables. --------------------------------------------------------
cwom_s3_bucket_folder="appd-cloud-kickstart-tools.s3.us-east-2.amazonaws.com/cwom"
cwom_platform_installer="update64_package-v${cwom_platform_release}.zip"
cwom_platform_sha512="0d19722fa0add299c3d64efbaf9bddb9c807cbac250c49c3c51bc823ba1c925f26980d7a5a02ec89ebd2ac99744121018d583051f3d4a3e36a02fbb624f3e851"

# install cwom platform prerequisites. -------------------------------------------------------------
# install repomd (xml-rpm-metadata) repository
yum -y install createrepo

# install the 'mod_ssl' module which also installs the apache http server.
yum -y install mod_ssl

# install the mariadb database server.
yum -y install mariadb-server

# install tomcat 7 web server by apache.
yum -y install tomcat

# install python utils package which contains management tools to manage an selinux environment.
yum -y install policycoreutils-python

# install dejavu font sets.
yum -y install dejavu-fonts-common dejavu-sans-fonts dejavu-sans-mono-fonts dejavu-serif-fonts

# configure the mariadb database. ------------------------------------------------------------------
# start the mariadb service and configure it to start at boot time.
systemctl start mariadb
systemctl enable mariadb

# check that the mariadb service is running.
systemctl status mariadb

# configure privileges for 'root' user.
echo "FLUSH PRIVILEGES; \
      GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'vmturbo' WITH GRANT OPTION; \
      FLUSH PRIVILEGES; " | /usr/bin/mysql -uroot &>/dev/null

# create temporary download directory. -------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos/cisco
cd ${kickstart_home}/provisioners/scripts/centos/cisco

# download the cwom platform installer. ------------------------------------------------------------
rm -f ${cwom_platform_installer}
curl --silent --remote-name https://${cwom_s3_bucket_folder}/${cwom_platform_installer}

# verify the downloaded binary.
echo "${cwom_platform_sha512} ${cwom_platform_installer}" | sha512sum --check
# update64_package-v${cwom_platform_release}.zip: OK

# extract cwom package binaries.
rm -f /tmp/cisco_temp.repo
rm -Rf /tmp/cisco
unzip ${cwom_platform_installer} -d /tmp/

# install the cwom platform binaries. --------------------------------------------------------------
# create a local cwom metadata repository.
createrepo --database /tmp/cisco
cp -p /tmp/cisco_temp.repo /etc/yum.repos.d/

# install the cwom packages.
yum -y install cwom-bundle cwom-config cwom-persistence cwom-platform cwom-presentation cwom-reports cwom-ui
#yum -y install cwom-*

# configure the cwom platform. ---------------------------------------------------------------------
# restart the mariadb service and check that it is running.
systemctl start mariadb
systemctl status mariadb

# initialize the cwom database.
cd /srv/rails/webapps/persistence/db/
./initialize_all.sh

# setup cwom platform page folders.
ln -s /srv/www/htdocs /srv/www/html
rm -Rf /var/www
ln -s /srv/www /var/.
rm -Rf /var/lib/tomcat
ln -s /srv/tomcat/ /var/lib/
mkdir -p /var/lib/wwwrun
chown -R apache.apache /var/lib/wwwrun

# tell selinux to allow httpd to connect to the network.
setsebool -P httpd_can_network_connect 1

# tell selinux to allow httpd to relay to the network.
setsebool -P httpd_can_network_relay 1

# allow cgi-scripts to run.
chcon -Rt httpd_sys_script_exec_t /var/www/cgi-bin

# setup cwom sudoers config.
cat <<EOF > /etc/sudoers.d/turbo_conf
# User alias specification
User_Alias ADMINS = apache, wwwrun, tomcat

# Cmnd alias specification
Cmnd_Alias SOFTWARE = /bin/fillup, /bin/rpm, /bin/cp, /usr/bin/yum, /usr/sbin/postmap, /usr/bin/unzip, /srv/tomcat/script/appliance/vmtsupport.sh, /sbin/setsebool, /bin/rm, /usr/bin/chown
ADMINS ALL=NOPASSWD: SOFTWARE
EOF

# change ssl.conf for j&j httpd server.
sed -i '0,/^SSLCipherSuite/{//d;}' /etc/httpd/conf.d/ssl.conf
sed -i 's/^SSLCipherSuite.*/SSLCipherSuite ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA256:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:!DSS/g' /etc/httpd/conf.d/ssl.conf

# start the cwom platform. -------------------------------------------------------------------------
# start the httpd service and configure it to start at boot time.
systemctl start httpd
systemctl enable httpd
systemctl status httpd

# start the tomcat service and configure it to start at boot time.
systemctl start tomcat
systemctl enable tomcat
systemctl status tomcat

# configure the cwom administrator and apply the license file. ------------------------------------
cd ${kickstart_home}/provisioners/scripts/centos/tools

# install administrator user config file.
cwom_login_config_file="cwom-login.config.topology"
if [ -f "$cwom_login_config_file" ]; then
  cp $cwom_login_config_file /srv/tomcat/data/config/login.config.topology
fi

# install cwom license file.
cwom_license_config_file="cwom-license.config.topology"
if [ -f "$cwom_license_config_file" ]; then
  cp $cwom_license_config_file /srv/tomcat/data/config/license.config.topology
fi

# potential future to-do items. --------------------------------------------------------------------
# set cwom configuration variables.
#cd ${kickstart_home}/provisioners/scripts/centos/tools
#cwom_admin_username="administrator"
#cwom_admin_password="<your_admin_password>"
#cwom_license_file="UCSPMFEAT20190409133840574.lic"

# verify cwom license file via rest api.
#if [ -f "$cwom_license_file" ]; then
#  curl --insecure -u "${cwom_admin_username}:${cwom_admin_password}" -X POST https://localhost/vmturbo/rest/licenses -H 'Accept: application/json' -H 'Content-Type: multipart/form-data' -F file=@${cwom_license_file}
#fi

# shutdown the cwom platform components. -----------------------------------------------------------
# stop the tomcat serice.
systemctl stop tomcat

# stop the apache http server.
systemctl stop httpd

# stop the mariadb service.
systemctl stop mariadb
