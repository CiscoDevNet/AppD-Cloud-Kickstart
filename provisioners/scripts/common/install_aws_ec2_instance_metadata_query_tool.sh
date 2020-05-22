#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Install AWS EC2 Instance Metadata Query Tool by Amazon.
#
# The AWS EC2 Instance Metadata Query Tool is a simple bash script that uses curl to query
# the EC2 instance Metadata from within a running EC2 instance.
#
# For more details, please visit:
#   https://aws.amazon.com/code/ec2-instance-metadata-query-tool/
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# install aws ec2 instance metadata query tool. ----------------------------------------------------
# create local bin directory (if needed).
mkdir -p /usr/local/bin
cd /usr/local/bin

# download ec2-metadata binary from aws s3 bucket.
rm -f ec2-metadata
wget http://s3.amazonaws.com/ec2metadata/ec2-metadata

# change execute permissions.
chmod 755 ec2-metadata

# set ec2-metadata environment variables.
PATH=/usr/local/bin:$PATH
export PATH

# verify installation.
ec2-metadata --help

# ec2-metadata command-line examples. --------------------------------------------------------------
# Example #1:
#   To get the AMI ID of the EC2 instance, run:
#
#   $ ec2-metadata -a
#   ami-id: ami-xxxxxxx
#
# Example #2:
#   To get the public hostname of the EC2 instance, run:
#
#   $ ec2-metadata -p
#   public-hostname: ec2-x-x-x-x.compute-1.amazonaws.com
#
# Example #3:
#   To get the local IPv4 address of the EC2 instance, run:
#
#   $ ec2-metadata -o
#   local-ipv4: 10.x.x.x
