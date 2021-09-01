#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Update Platform Configurations by AppDynamics.
#
# Configuration settings on the Enterprise Console are separated into three categories:
# Platform, Controller, and Events Service Settings.
#
# Controller Settings --> Appserver Configurations
# The AppServer Configurations allow you to edit most of the domain.xml configurations.
# You can also change the ports, set the external load balancer url, and update the controller
# from a smaller to a higher profile. The configurations are categorized under Basic, JVM Options,
# and SSL Certificate Management.
#
# For more details, please visit:
#   https://docs.appdynamics.com/latest/en/application-performance-monitoring-platform/enterprise-console/administer-the-enterprise-console/update-platform-configurations
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with installed user privilege ('root' OR non-root user).
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] appdynamics platform service configuration parameters.
appd_controller_external_url="${appd_controller_external_url:-}"

# [OPTIONAL] appdynamics platform install parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
set +x  # temporarily turn command display OFF.
appd_platform_admin_username="${appd_platform_admin_username:-admin}"
appd_platform_admin_password="${appd_platform_admin_password:-welcome1}"
set -x  # turn command display back ON.
appd_platform_home="${appd_platform_home:-platform}"
appd_platform_name="${appd_platform_name:-My Platform}"
appd_platform_product_home="${appd_platform_product_home:-product}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Update Platform Configurations by AppDynamics.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with installed user privilege ('root' OR non-root user).

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] appdynamics platform service configuration parameters.
    [root]# export appd_controller_external_url="http://ext-url:port"   # controller external load balancer url.

  [OPTIONAL] appdynamics platform install parameters [w/ defaults].
    [root]# export appd_home="/opt/appdynamics"                         # [optional] appd home (defaults to '/opt/appdynamics').
    [root]# export appd_platform_admin_username="admin"                 # [optional] platform admin user name (defaults to user 'admin').
    [root]# export appd_platform_admin_password="welcome1"              # [optional] platform admin password (defaults to 'welcome1').
    [root]# export appd_platform_home="platform"                        # [optional] platform home folder (defaults to 'machine-agent').
    [root]# export appd_platform_name="My Platform"                     # [optional] platform name (defaults to 'My Platform').
    [root]# export appd_platform_product_home="product"                 # [optional] platform base installation directory for products
                                                                        #            (defaults to 'product').
  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -z "$appd_controller_external_url" ]; then
  echo "Error: 'appd_controller_external_url' environment variable not set."
  usage
  exit 1
fi

# set appdynamics platform installation variables. -------------------------------------------------
appd_platform_folder="${appd_home}/${appd_platform_home}"
appd_product_folder="${appd_home}/${appd_platform_home}/${appd_platform_product_home}"

# verify appdynamics enterprise console installation. ----------------------------------------------
cd ${appd_platform_folder}/platform-admin/bin
${appd_platform_folder}/platform-admin/bin/platform-admin.sh show-platform-admin-version

# login to the appdynamics platform. ---------------------------------------------------------------
set +x  # temporarily turn command display OFF.
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  login \
    --user-name "${appd_platform_admin_username}" \
    --password "${appd_platform_admin_password}"
set -x  # turn command display back ON.
#export APPD_CURRENT_PLATFORM="${appd_platform_name}"

# configure appdynamics controller external load balancer url. -------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  update-service-configurations \
    --platform-name "${appd_platform_name}" \
    --service controller \
    --job update-configs \
    --args controllerExternalUrl="${appd_controller_external_url}"

# verify controller external load balancer url. ----------------------------------------------------
${appd_platform_folder}/platform-admin/bin/platform-admin.sh \
  list-service-configurations \
    --platform-name "${appd_platform_name}" \
    --service controller \
  | grep controllerExternalUrl
