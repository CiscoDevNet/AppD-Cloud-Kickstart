#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Delete an AWS EKS cluster with eksctl utility
# 
# export appd_aws_eks_user_name=User-0X
# export appd_aws_eks_region=eu-west-3
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
  Delete an AWS EKS cluster with eksctl utility

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.
        Script should be run with 'root' privilege.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] eksctl command parameters
    [root]# export appd_aws_eks_user_name="User-0X"                        # lab participant user name
    [root]# export appd_aws_eks_region="eu-west-3"                         # AWS region ('eu-central-1', 'eu-west-2', or 'eu-west-3')

  [OPTIONAL] eksctl command parameters [w/ defaults].
    [root]# export appd_aws_eks_name="AD-Capital-user-01"                  # [optional] eks cluster name (defaults to 'AD-Capital-${appd_aws_eks_user_name}')

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

# run eksctl command to delete the eks cluster. ----------------------------------------------
#echo "eksctl delete cluster --name="${appd_aws_eks_name}" --region="${appd_aws_eks_region}

set -x  # turn command display back ON.

eksctl delete cluster --name=${appd_aws_eks_name} --region=${appd_aws_eks_region}




