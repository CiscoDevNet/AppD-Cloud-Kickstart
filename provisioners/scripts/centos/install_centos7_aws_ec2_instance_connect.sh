#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install EC2 Instance Connect for CentOS 7.
#
# Amazon EC2 Instance Connect provides a simple and secure way to connect to your Linux instances
# with Secure Shell (SSH). With EC2 Instance Connect, you use AWS Identity and Access Management
# (IAM) policies and principals to control SSH access to your instances, removing the need to share
# and manage SSH keys. All connection requests using EC2 Instance Connect are logged to AWS
# CloudTrail so that you can audit connection requests.
#
# You can use EC2 Instance Connect to connect to instances that have public or private IP addresses.
# For more information, see Connect using EC2 Instance Connect.
#
# For more details, please visit:
#   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-methods.html
#   https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-connect-set-up.html
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# [OPTIONAL] appdynamics cloud kickstart home folder [w/ default].
kickstart_home="${kickstart_home:-/opt/appd-cloud-kickstart}"

# create temporary download directory. -------------------------------------------------------------
mkdir -p ${kickstart_home}/provisioners/scripts/centos/aws
cd ${kickstart_home}/provisioners/scripts/centos/aws

# download ec2 instance connect rpm files. ---------------------------------------------------------
curl --silent --location https://amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com/latest/linux_amd64/ec2-instance-connect.rhel8.rpm --output ec2-instance-connect.rpm
curl --silent --location https://amazon-ec2-instance-connect-us-west-2.s3.us-west-2.amazonaws.com/latest/linux_amd64/ec2-instance-connect-selinux.noarch.rpm --output ec2-instance-connect-selinux.rpm

# install ec2 instance connect rpm files. ----------------------------------------------------------
yum -y install ec2-instance-connect.rpm ec2-instance-connect-selinux.rpm
