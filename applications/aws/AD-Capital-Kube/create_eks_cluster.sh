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
appd_aws_eks_version="${appd_aws_eks_version:-1.15}"
appd_aws_eks_name="${appd_aws_eks_name:-AD-Capital-${appd_aws_eks_user_name}}"
appd_aws_eks_environment="${appd_aws_eks_environment:-Lab-Env-${appd_aws_eks_user_name}}"
appd_aws_eks_nodes="${appd_aws_eks_nodes:-2}"
appd_aws_eks_node_type="${appd_aws_eks_node_type:-m5a.large}"
appd_aws_eks_ssh_public_key="${appd_aws_eks_ssh_public_key:-AppD-Cloud-Kickstart-AWS}"

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
    [ec2-user]$ export appd_aws_eks_user_name="Lab-User-01"                     # lab participant user name.
    [ec2-user]$ export appd_aws_eks_region="us-east-1"                          # aws region (us-east-1 or us-east-2).

  [OPTIONAL] eksctl command parameters [w/ defaults].
    [ec2-user]$ export appd_aws_eks_zones="us-east-1a,us-east-1b,us-east-1c"    # [optional] aws availability zones.
    [ec2-user]$ export appd_aws_eks_version="1.15"                              # [optional] kubernetes version (defaults to '1.15').
                                                                                #            valid versions:
                                                                                #              '1.13', '1.14', '1.15'
    [ec2-user]$ export appd_aws_eks_name="AD-Capital-Lab-User-01"               # [optional] eks cluster name (defaults to 'AD-Capital-${appd_aws_eks_user_name}')
    [ec2-user]$ export appd_aws_eks_environment="Lab-Env-Lab-User-01"           # [optional] eks environment decription (defaults to 'Lab-Env-${appd_aws_eks_user_name}')
    [ec2-user]$ export appd_aws_eks_nodes="2"                                   # [optional] number of eks worker nodes (defaults to '2')
    [ec2-user]$ export appd_aws_eks_node_type="m5a.large"                       # [optional] type of ec2 instance for nodes (defaults to user 'm5a.large')
    [ec2-user]$ export appd_aws_eks_ssh_public_key="AppD-Cloud-Kickstart-AWS"   # [optional] public key used to ssh to eks cluster (defaults to 'AppD-Cloud-Kickstart-AWS')

  --------
  Example:
  --------
    [ec2-user]$ $0
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
      1.13|1.14|1.15)
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
