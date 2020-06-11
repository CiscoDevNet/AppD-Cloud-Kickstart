#!/bin/sh -eux
# create new user with associated groups on centos linux 7.x.

# set default values for input environment variables if not set. -----------------------------------
user_name="${user_name:-}"
user_group="${user_group:-}"
user_password="${user_password:-}"
user_id="${user_id:-}"
user_comment="${user_comment:-$user_name}"
user_supplementary_groups="${user_supplementary_groups:-}"
user_sudo_privileges="${user_sudo_privileges:-false}"
user_home="${user_home:-}"
user_install_env="${user_install_env:-false}"
user_docker_profile="${user_docker_profile:-false}"
user_prompt_color="${user_prompt_color:-green}"

# set default value for appdynamics cloud kickstart home environment variable if not set. ----------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
    [root]# export user_name="user1"                            # user name.
    [root]# export user_group="group1"                          # user login group.
    [root]# export user_password="password"                     # [optional] user password.
    [root]# export user_id="1001"                               # [optional] custom user id.
    [root]# export user_comment="user1"                         # [optional] user comment [full name] (defaults to 'user_name').
    [root]# export user_supplementary_groups="grp2,grp3"        # [optional] comma separated list of groups.
    [root]# export user_sudo_privileges="true"                  # [optional] user sudo privileges boolean (defaults to 'false').
    [root]# export user_home="/home/user1"                      # [optional] user home directory path.
    [root]# export user_install_env="true"                      # [optional] user install environment (defaults to 'false').

    NOTE: if 'user_install_env' is 'true':
          the following [optional] pass-thru env variables may be defined:

    [root]# export user_docker_profile="true"                   # [optional] user docker profile (defaults to 'false').
    [root]# export user_prompt_color="yellow"                   # [optional] user prompt color (defaults to 'green').
                                                                #            valid colors:
                                                                #              'black', 'blue', 'cyan', 'green', 'magenta', 'red', 'white', 'yellow'

    [root]# export kickstart_home="/opt/appd-cloud-kickstart"   # [optional] kickstart home (defaults to '/opt/appd-cloud-kickstart').
    [root]# $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -z "$user_name" ]; then
  echo "Error: 'user_name' environment variable not set."
  usage
  exit 1
fi

if [ -z "$user_group" ]; then
  echo "Error: 'user_group' environment variable not set."
  usage
  exit 1
fi

if [ -n "$user_prompt_color" ]; then
  case $user_prompt_color in
      black|blue|cyan|green|magenta|red|white|yellow)
        ;;
      *)
        echo "Error: invalid 'user_prompt_color'."
        usage
        exit 1
        ;;
  esac
fi

# check if user already exists. --------------------------------------------------------------------
if [ "$(getent passwd ${user_name})" ]; then
  exit 0
fi

# create user and add to associated groups. --------------------------------------------------------
# set default useradd option to create home directory.
useradd_options="-m"

# check for custom home directory.
if [ -n "$user_home" ]; then
  useradd_options="${useradd_options} -d ${user_home}"
fi

# check for custom user id.
if [ -n "$user_id" ]; then
  useradd_options="${useradd_options} -u ${user_id}"
fi

# create new user.
useradd ${useradd_options} -g ${user_group} ${user_name}

# modify default password.
if [ -n "$user_password" ]; then
  echo "${user_name}:${user_password}" | chpasswd
fi

# add user comment (usually a full name).
if [ -n "$user_comment" ]; then
  usermod -c "${user_comment}" ${user_name}
fi

# add user to supplementary groups.
if [ -n "$user_supplementary_groups" ]; then
  usermod -aG ${user_supplementary_groups} ${user_name}
fi

# add user to sudoers. -----------------------------------------------------------------------------
if [ "$user_sudo_privileges" == "true" ]; then
  echo "%${user_group} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${user_group}
fi

# create environment profile for the user. ---------------------------------------------------------
if [ "$user_install_env" == "true" ]; then
  # NOTE: if 'user_install_env' is 'true'--
  #       the following [optional] pass-thru env variables may be defined:
  #         user_docker_profile:                            # [optional] user docker profile (defaults to 'false').
  #         user_prompt_color:                              # [optional] user prompt color (defaults to 'green').
  #            valid colors are:
  #              'black', 'blue', 'cyan', 'green', 'magenta', 'red', 'white', 'yellow'
  cd ${kickstart_home}/provisioners/scripts/common
  chmod 755 install_user_env.sh
  ./install_user_env.sh
fi
