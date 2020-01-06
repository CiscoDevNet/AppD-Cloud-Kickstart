#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Create an AWS EKS cluster with eksctl utility
# 
# export appd_aws_eks_user_name=User-0X
# export appd_aws_eks_region=us-east-1
# 
# For more details, please visit:
#   https://github.com/weaveworks/eksctl
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#       Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] appdynamics account parameters.
set +x  # temporarily turn command display OFF.
appd_aws_eks_user_name="${appd_aws_eks_user_name:-}"
appd_aws_eks_region="${appd_aws_eks_region:-}"
set -x  # turn command display back ON.

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Create an AWS EKS cluster with eksctl utility

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] eksctl command parameters
    [root]# export appd_aws_eks_user_name="User-0X"                        # lab participant user name
    [root]# export appd_aws_eks_region="us-east-1"                         # AWS region (us-east-1 or us-east-2)

  [OPTIONAL] eksctl command parameters [w/ defaults].
    [root]# export appd_aws_eks_name="AD-Capital-User-0X"                  # [optional] eks cluster name (defaults to 'AD-Capital-${appd_aws_eks_user_name}')
    [root]# export appd_aws_eks_environment="Lab-Env-User-0X"              # [optional] eks environment decription (defaults to 'Lab-Env-${appd_aws_eks_user_name}')
    [root]# export appd_aws_eks_nodes="2"                                  # [optional] number of eks worker nodes (defaults to '2')
    [root]# export appd_aws_eks_node_type="m5a.large"                      # [optional] type of EC2 instance for nodes (defaults to user 'm5a.large')
    [root]# export appd_aws_eks_ssh_public_key="AppD-Cloud-Kickstart-AWS"  # [optional] public key used to ssh to eks cluster (defaults to 'AppD-Cloud-Kickstart-AWS')

  --------
  Example:
  --------
    [root]# $0
EOF
}


# validate mandatory environment variables. --------------------------------------------------
set +x  # temporarily turn command display OFF.

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

set -x  # turn command display back ON.


# set optional environment variables. --------------------------------------------------------
set +x  # temporarily turn command display OFF.

appd_aws_eks_name="AD-Capital-${appd_aws_eks_user_name}"
appd_aws_eks_environment="Lab-Env-${appd_aws_eks_user_name}"
appd_aws_eks_nodes="${appd_aws_eks_nodes:-2}"
appd_aws_eks_node_type="${appd_aws_eks_node_type:-m5a.large}"
appd_aws_eks_ssh_public_key="${appd_aws_eks_ssh_public_key:-AppD-Cloud-Kickstart-AWS}"

# run eksctl command to create the eks cluster. ----------------------------------------------
#echo "eksctl create cluster --name="${appd_aws_eks_name}" --region="${appd_aws_eks_region}" --tags environment="${appd_aws_eks_environment}" --nodes="${appd_aws_eks_nodes}" --node-type="${appd_aws_eks_node_type}" --node-ami=auto --ssh-access --ssh-public-key="${appd_aws_eks_ssh_public_key}

set -x  # turn command display back ON.

eksctl create cluster --name=${appd_aws_eks_name} --region=${appd_aws_eks_region} --tags environment=${appd_aws_eks_environment} --nodes=${appd_aws_eks_nodes} --node-type=${appd_aws_eks_node_type} --node-ami=auto --ssh-access --ssh-public-key=${appd_aws_eks_ssh_public_key}

