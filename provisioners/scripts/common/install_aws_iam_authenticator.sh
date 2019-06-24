#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AWS IAM Authenticator for Amazon Kubernetes and kubectl.
#
# Amazon EKS uses IAM to provide authentication to your Kubernetes cluster through the AWS
# IAM Authenticator for Kubernetes. Beginning with Kubernetes version 1.10, you can configure
# the stock kubectl client to work with Amazon EKS by installing the AWS IAM Authenticator for
# Kubernetes and modifying your kubectl configuration file to use it for authentication.
#
# For more details, please visit:
#   https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install aws iam authenticator. -------------------------------------------------------------------
aws_iam_authenticator_release="1.13.7"
aws_iam_authenticator_date="2019-06-11"

# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download aws iam authenticator binary from github.com.
rm -f aws-iam-authenticator
curl --silent --location "https://amazon-eks.s3-us-west-2.amazonaws.com/${aws_iam_authenticator_release}/${aws_iam_authenticator_date}/bin/linux/amd64/aws-iam-authenticator" --output aws-iam-authenticator
chown root:root aws-iam-authenticator

# change execute permissions.
chmod 755 aws-iam-authenticator

# set aws iam authenticator environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
aws-iam-authenticator help
