#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AppDynamics Ansible Collection for Agent Management.
#
# The AppDynamics Ansible Collection installs and configures AppDynamics agents. All supported
# agents are downloaded from the download portal or supported repositories. This makes it easy to
# acquire and upgrade agents declaratively.
#
# For more details, please visit:
#   https://docs.appdynamics.com/appd/23.x/23.5/en/application-monitoring/install-app-server-agents/agent-management/standalone-host-platforms/ansible
#   https://galaxy.ansible.com/appdynamics/agents
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       Requires Ansible Core >= 2.12.0.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics ansible collection install parameters [w/ defaults].
user_name="${user_name:-ec2-user}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Install AppDynamics Ansible Collection for Agent Management.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Requires Ansible Core >= 2.12.0.
        Script should be run with 'root' privilege.

  Example:
    [root]# export user_name="ec2-user"                         # user name.
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -z "$user_name" ]; then
  echo "Error: 'user_name' environment variable not set."
  usage
  exit 1
fi

if [ "$user_name" = "root" ]; then
  echo "Error: 'user_name' should NOT be 'root'."
  usage
  exit 1
fi

# create ansible home directory (if needed). -------------------------------------------------------
mkdir -p /home/${user_name}/.ansible
chown -R ${user_name}:${user_name} /home/${user_name}/.ansible

# validate required ansible core version. ----------------------------------------------------------
current_core_version=$(runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} ansible --version" - ${user_name} | awk '/core/ {print $3}' | awk -F ']' '{print $1}')
minmum_core_version="2.12.0"

echo "current_core_version: ${current_core_version}"
echo "minmum_core_version: ${minmum_core_version}"

# is current ansible core version < minimum appd-required ansible core version. --------------------
if [ "$current_core_version" \< "$minmum_core_version" ]; then
  echo "Error: AppDynamics Ansible Collection requires Ansible Core version '${current_core_version}' to be >= '${minimum_core_version}'."
  usage
  exit 1
fi

# install appdynamics ansible collection for agent management. -------------------------------------
# install ansible collection in the user's home account.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} ansible-galaxy collection install --pre appdynamics.agents --force" - ${user_name}

# validate appdynamics ansible collection.
runuser -c "PATH=/home/${user_name}/.local/bin:/usr/local/bin:${PATH} ansible-galaxy collection list appdynamics.agents" - ${user_name}
