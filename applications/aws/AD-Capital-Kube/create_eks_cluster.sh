#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Create an AWS EKS cluster with eksctl utility from Weaveworks.
#
# eksctl is a simple CLI tool for creating clusters on EKS, Amazon’s managed Kubernetes service
# for EC2. It is written in Go, and uses CloudFormation.
#
# For more details, please visit:
#   https://eksctl.io/
#   https://github.com/weaveworks/eksctl
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] eksctl command parameters.
appd_aws_eks_user_name="${appd_aws_eks_user_name:-}"
appd_aws_eks_region="${appd_aws_eks_region:-}"

# [OPTIONAL] eksctl command parameters [w/ defaults].
appd_aws_eks_zones="${appd_aws_eks_zones:-}"
appd_aws_eks_version="${appd_aws_eks_version:-1.29}"
appd_aws_eks_name="${appd_aws_eks_name:-AD-Capital-${appd_aws_eks_user_name}}"
appd_aws_eks_environment="${appd_aws_eks_environment:-Lab-Env-${appd_aws_eks_user_name}}"
appd_aws_eks_nodes="${appd_aws_eks_nodes:-2}"
appd_aws_eks_node_type="${appd_aws_eks_node_type:-m5a.large}"
appd_aws_eks_ssh_public_key="${appd_aws_eks_ssh_public_key:-AppD-Cloud-Kickstart}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Create an AWS EKS cluster with eksctl utility from Weaveworks.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] eksctl command parameters.
    [centos]$ export appd_aws_eks_user_name="Lab-User-01"                       # lab participant user name.
    [centos]$ export appd_aws_eks_region="us-east-1"                            # aws region (us-east-1 or us-east-2).

  [OPTIONAL] eksctl command parameters [w/ defaults].
    [centos]$ export appd_aws_eks_zones="us-east-1a,us-east-1b,us-east-1c"      # [optional] aws availability zones.
    [centos]$ export appd_aws_eks_version="1.29"                                # [optional] kubernetes version (defaults to '1.29').
                                                                                #            valid versions:
                                                                                #              '1.24', '1.25', '1.26', '1.27', '1.28', 1.29, and '1.30'
    [centos]$ export appd_aws_eks_name="AD-Capital-Lab-User-01"                 # [optional] eks cluster name (defaults to 'AD-Capital-${appd_aws_eks_user_name}')
    [centos]$ export appd_aws_eks_environment="Lab-Env-Lab-User-01"             # [optional] eks environment decription (defaults to 'Lab-Env-${appd_aws_eks_user_name}')
    [centos]$ export appd_aws_eks_nodes="2"                                     # [optional] number of eks worker nodes (defaults to '2')
    [centos]$ export appd_aws_eks_node_type="m5a.large"                         # [optional] type of ec2 instance for nodes (defaults to user 'm5a.large')
    [centos]$ export appd_aws_eks_ssh_public_key="AppD-Cloud-Kickstart"         # [optional] public key used to ssh to eks cluster (defaults to 'AppD-Cloud-Kickstart')

  --------
  Example:
  --------
    [centos]$ $0
EOF
}

# validate environment variables. ------------------------------------------------------------------
if [ -z "$appd_aws_eks_user_name" ]; then
  echo "Error: 'appd_aws_eks_user_name' environment variable not set."
  usage
  exit 1
fi

if [ -z "$appd_aws_eks_region" ]; then
  echo "Error: 'appd_aws_eks_region' environment variable not set."
  usage
  exit 1
fi

if [ -n "$appd_aws_eks_version" ]; then
  case $appd_aws_eks_version in
      1.24|1.25|1.26|1.27|1.28|1.29|1.30)
        ;;
      *)
        echo "Error: invalid 'appd_aws_eks_version'."
        usage
        exit 1
        ;;
  esac
fi

# populate 'zones' option if set. ------------------------------------------------------------------
if [ -z "$appd_aws_eks_zones" ]; then
  appd_aws_eks_zones_option=""
else
  appd_aws_eks_zones_option="--zones=${appd_aws_eks_zones}"
fi

# run eksctl command to create the eks cluster. ----------------------------------------------------
eksctl create cluster --name=${appd_aws_eks_name} --region=${appd_aws_eks_region} ${appd_aws_eks_zones_option} --version=${appd_aws_eks_version} --tags environment=${appd_aws_eks_environment} --nodes=${appd_aws_eks_nodes} --node-type=${appd_aws_eks_node_type} --node-ami=auto --ssh-access --ssh-public-key=${appd_aws_eks_ssh_public_key}
