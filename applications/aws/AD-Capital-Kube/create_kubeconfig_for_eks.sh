#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Update or create the kubeconfig for the AWS EKS cluster.
#
# A kubeconfig file is a file used to configure access to Kubernetes when used in conjunction with
# the kubectl commandline tool (or other clients). The kubectl command-line tool uses the kubeconfig
# file to communicate with the API server of a cluster.
#
# By default, kubectl looks for a file named config in the $HOME/.kube directory.
# 
# For more details, please visit:
#   https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html
#   https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       See 'usage()' function below for environment variable descriptions.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [MANDATORY] aws eks kubeconfig parameters.
appd_aws_eks_user_name="${appd_aws_eks_user_name:-}"
appd_aws_eks_region="${appd_aws_eks_region:-}"

# [OPTIONAL] aws eks kubeconfig parameters [w/ defaults].
appd_aws_eks_name="${appd_aws_eks_name:-AD-Capital-${appd_aws_eks_user_name}}"

# define usage function. ---------------------------------------------------------------------------
usage() {
  cat <<EOF
Usage:
  Update or create the kubeconfig for the AWS EKS cluster.

  NOTE: All inputs are defined by external environment variables.
        Optional variables have reasonable defaults, but you may override as needed.

  -------------------------------------
  Description of Environment Variables:
  -------------------------------------
  [MANDATORY] aws eks kubeconfig parameters.
    $ export appd_aws_eks_user_name="Lab-User-01"               # lab participant user name
    $ export appd_aws_eks_region="eu-west-3"                    # AWS region ('eu-central-1', 'eu-west-2', or 'eu-west-3')

  [OPTIONAL]eksctl command parameters  [w/ defaults].
    $ export appd_aws_eks_name="AD-Capital-Lab-User-01"         # [optional] eks cluster name (defaults to 'AD-Capital-\${appd_aws_eks_user_name}')

  --------
  Example:
  --------
    [root]# $0
EOF
}

# validate mandatory environment variables. --------------------------------------------------------
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

# update or create the kubeconfig for the eks cluster. ---------------------------------------------
aws eks --region ${appd_aws_eks_region} update-kubeconfig --name ${appd_aws_eks_name}

# test the eks cluster configuration.
kubectl get services
