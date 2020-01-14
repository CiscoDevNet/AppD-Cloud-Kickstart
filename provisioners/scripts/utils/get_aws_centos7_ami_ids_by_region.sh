#!/bin/sh
# get the latest aws source ami id's for centos 7 in each region. (currently supports north america and europe.)
# NOTE: this script uses the 'jq' command-line json processor utility for formatting the output returned by the AWS CLI.

# check if 'jq' is installed.
if [ ! -f "/usr/local/bin/jq" ]; then
  echo "Error: 'jq' command-line json processor utility not found."
  echo "NOTE: This script uses the 'jq' command-line json processor utility for formatting the output returned by the AWS CLI."
  echo "      For more information, visit: https://github.com/stedolan/jq/releases/"
fi

# print comment line with date. --------------------------------------------------------------------
# get current date.
curdate=$(date +"%d %b %Y")
echo "# CentOS 7.7 AMI Image IDs as of: ${curdate}."

# loop for each aws region. ------------------------------------------------------------------------
# initialize aws regions for north america and europe.
aws_region_ids_array=( "ap-southeast-2" "ca-central-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-west-3" "sa-east-1" "us-east-1" "us-east-2" "us-west-1" "us-west-2" )
aws_region_names_array=( "Sydney" "Central" "Frankfurt" "Ireland" "London" "Paris" "São Paulo" "N. Virginia" "Ohio" "N. California" "Oregon" )

# initialize array index.
ii=0
for aws_region in "${aws_region_ids_array[@]}"; do
  # retrieve ami source image id.
  aws_ami_source=$(aws --region=${aws_region} ec2 describe-images --owners aws-marketplace --filters 'Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce' 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')
  echo "#aws_ami_source=\"${aws_ami_source}\"     # CentOS 7.7 AMI (HVM), SSD Volume Type: ${aws_region} [${aws_region_names_array[$ii]}]"

  # increment array index.
  ii=$(($ii + 1))
done

echo "#export aws_ami_source"

# output will look like the following: -------------------------------------------------------------
# CentOS 7.7 AMI Image IDs as of: 14 Jan 2020.
#aws_ami_source="ami-08bd00d7713a39e7d"     # CentOS 7.7 AMI (HVM), SSD Volume Type: ap-southeast-2 [Sydney]
#aws_ami_source="ami-033e6106180a626d0"     # CentOS 7.7 AMI (HVM), SSD Volume Type: ca-central-1 [Central]
#aws_ami_source="ami-04cf43aca3e6f3de3"     # CentOS 7.7 AMI (HVM), SSD Volume Type: eu-central-1 [Frankfurt]
#aws_ami_source="ami-0ff760d16d9497662"     # CentOS 7.7 AMI (HVM), SSD Volume Type: eu-west-1 [Ireland]
#aws_ami_source="ami-0eab3a90fc693af19"     # CentOS 7.7 AMI (HVM), SSD Volume Type: eu-west-2 [London]
#aws_ami_source="ami-0e1ab783dc9489f34"     # CentOS 7.7 AMI (HVM), SSD Volume Type: eu-west-3 [Paris]
#aws_ami_source="ami-0b8d86d4bf91850af"     # CentOS 7.7 AMI (HVM), SSD Volume Type: sa-east-1 [São Paulo]
#aws_ami_source="ami-02eac2c0129f6376b"     # CentOS 7.7 AMI (HVM), SSD Volume Type: us-east-1 [N. Virginia]
#aws_ami_source="ami-0f2b4fc905b0bd1f1"     # CentOS 7.7 AMI (HVM), SSD Volume Type: us-east-2 [Ohio]
#aws_ami_source="ami-074e2d6769f445be5"     # CentOS 7.7 AMI (HVM), SSD Volume Type: us-west-1 [N. California]
#aws_ami_source="ami-01ed306a12b7d1c96"     # CentOS 7.7 AMI (HVM), SSD Volume Type: us-west-2 [Oregon]
#export aws_ami_source
