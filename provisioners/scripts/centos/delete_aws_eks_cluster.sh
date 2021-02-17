#!/bin/sh -eux
# delete aws eks cluster for specified user on centos linux 7.x.

# set empty default values for user env variables if not set. --------------------------------------
user_name="${user_name:-}"
appd_aws_eks_user_name="${appd_aws_eks_user_name:-Lab-User-${user_name: -2}}"
appd_aws_eks_region="${appd_aws_eks_region:-us-east-1}"

# validate environment variable. -------------------------------------------------------------------
if [ -z "$user_name" ]; then
  echo "Error: 'user_name' environment variable not set."
  usage
  exit 1
fi

# delete aws eks cluster. --------------------------------------------------------------------------
# export the environment variables for use by the script.
export appd_aws_eks_user_name
export appd_aws_eks_region

cd AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube
./delete_eks_cluster.sh
