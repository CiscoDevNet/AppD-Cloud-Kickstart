#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install Cloud9 runtime environment.
# NOTE: AWS now supports multiple linux distributions for Cloud9 including CentOS and Ubuntu.
#
# AWS Cloud9 is a cloud-based integrated development environment (IDE) that lets you write, run, and
# debug your code with just a browser. It includes a code editor, debugger, and terminal. Cloud9
# comes prepackaged with essential tools for popular programming languages, including JavaScript,
# Python, PHP, and more, so you don’t need to install files or configure your development machine to
# start new projects.
#
# Since your Cloud9 IDE is cloud-based, you can work on your projects from your office, home, or
# anywhere using an internet-connected machine. With Cloud9, you can quickly share your development
# environment with your team, enabling you to pair program and track each other's inputs in real
# time.
#
# For secure enviroments, you can restrict incoming traffic to only the IP address ranges that AWS
# Cloud9 uses to connect over SSH to AWS cloud compute instances (for example, Amazon EC2 instances)
# in an Amazon VPC or your own servers in your network. To determine the correct CIDR blocks, use
# the following command to download the 'ip-ranges.json' file and filter the IP CIDR blocks for a
# specific AWS region ('us-west-1' in this example) using 'jq':
#
#   curl -sL https://ip-ranges.amazonaws.com/ip-ranges.json | jq '.prefixes[] | select(.service=="CLOUD9") | select(.region=="us-west-1")'
#
# For more details, please visit:
#   https://aws.amazon.com/cloud9/
#   https://docs.aws.amazon.com/cloud9/latest/user-guide/ip-ranges.html
#   https://docs.aws.amazon.com/general/latest/gr/aws-ip-ranges.html
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
user_name="${user_name:-}"

# set default value for kickstart home environment variable if not set. ----------------------------
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  All inputs are defined by external environment variables.
  Script should be run with 'root' privilege.
  Example:
    [root]# export user_name="ec2-user"                         # user name.
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

if [ "$user_name" = "root" ]; then
  echo "Error: 'user_name' should NOT be 'root'."
  usage
  exit 1
fi

# install cloud9 runtime enviroment. ---------------------------------------------------------------
# add 'glibc-static' library for centos-like installations.
user_host_os=$(hostnamectl | awk '/Operating System/ {printf "%s %s %s %s %s", $3, $4, $5, $6, $7}' | xargs)
case $user_host_os in
  "CentOS Linux 7 (Core)")
    yum -y install glibc-static
    ;;
  "Amazon Linux 2023"|"Fedora 34 (Cloud Edition)")
    dnf -y install glibc-static
    ;;
  # in centos 8 like environments, the 'glibc-static' library is found in the 'powertools' repo.
  "AlmaLinux 8.7 (Stone Smilodon)"|"CentOS Stream 8"|"Rocky Linux 8.6 (Green Obsidian)")
    dnf -y install dnf-plugins-core
    dnf -y install epel-release
    dnf config-manager --set-enabled powertools
    dnf -y install glibc-static
    ;;
  # in centos 9 like environments, the 'glibc-static' library is found in the 'crb' repo.
  "AlmaLinux 9.1 (Lime Lynx)"|"CentOS Stream 9"|"Rocky Linux 9.1 (Blue Onyx)")
    dnf -y install dnf-plugins-core
    dnf -y install epel-release
    dnf config-manager --set-enabled crb
    dnf -y install glibc-static
    ;;
  *)
    ;;
esac

# install the cloud9 runtime environment in the user's home directory ('~/.c9').
case $user_host_os in
  # for newer os environments that don't have 'python2', we need to run the new c9 v2.0.0 installer script.
  "AlmaLinux 9.1 (Lime Lynx)"|"Amazon Linux 2023"|"CentOS Stream 9"|"Fedora 34 (Cloud Edition)"|"Rocky Linux 9.1 (Blue Onyx)"|"Ubuntu 20.04.6 LTS"|"Ubuntu 22.04.2 LTS"|"Ubuntu 22.10")
    runuser -c "${kickstart_home}/provisioners/scripts/aws/c9-install-2.0.0.sh" - ${user_name}
    ;;
  *)
    runuser -c "${kickstart_home}/provisioners/scripts/aws/c9-install.sh" - ${user_name}
    ;;
esac

# aws toolkit uses a file watcher utility that monitors changes to files and directories.
# increase the maximum number of files that can be handled by file watcher to avoid errors.
sysctlfile="/etc/sysctl.conf"
fscmd="fs.inotify.max_user_watches = 524288"
if [ -f "$sysctlfile" ]; then
  sysctl fs.inotify.max_user_watches
  grep -qF "${fscmd}" ${sysctlfile} || echo "${fscmd}" >> ${sysctlfile}
  sysctl -p ${sysctlfile}
  sysctl fs.inotify.max_user_watches
fi
