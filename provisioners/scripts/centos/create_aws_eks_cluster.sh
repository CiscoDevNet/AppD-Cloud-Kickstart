#!/bin/sh -eux
# create aws eks cluster for specified user on centos linux 7.x.

# set empty default values for user env variables if not set. --------------------------------------
user_name="${user_name:-}"
appd_aws_eks_user_name="${appd_aws_eks_user_name:-Lab-User-${user_name: -2}}"
appd_aws_eks_region="${appd_aws_eks_region:-us-east-1}"
appd_aws_eks_zones="${appd_aws_eks_zones:-}"
#appd_aws_eks_zones="${appd_aws_eks_zones:-us-east-1a,us-east-1b,us-east-1c}"
appd_aws_eks_version="${appd_aws_eks_version:-1.19}"

# validate environment variable. -------------------------------------------------------------------
if [ -z "$user_name" ]; then
  echo "Error: 'user_name' environment variable not set."
# usage
  exit 1
fi

# create aws eks cluster. --------------------------------------------------------------------------
# get appd-cloud-kickstart project.
cd /home/${user_name}
git clone https://github.com/Appdynamics/AppD-Cloud-Kickstart.git
cd AppD-Cloud-Kickstart
git fetch origin
#git checkout -b cleur20-lab origin/cleur20-lab

# get ad-capital-kube project.
#cd /home/${user_name}
#git clone https://github.com/Appdynamics/AD-Capital-Kube.git
#cd AD-Capital-Kube
#git fetch origin

cd /home/${user_name}

# export the environment variables for use by the script.
export appd_aws_eks_user_name
export appd_aws_eks_region
export appd_aws_eks_zones
export appd_aws_eks_version

cd AppD-Cloud-Kickstart/applications/aws/AD-Capital-Kube
./create_eks_cluster.sh
