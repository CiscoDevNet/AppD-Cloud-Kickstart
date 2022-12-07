#!/bin/bash
# get the latest aws source ami id's for centos 7 in each region. (currently supports north america and europe.)
# NOTE: this script uses the 'jq' command-line json processor utility for formatting the output returned by the AWS CLI.

# check if 'jq' is installed.
if [ ! -f "/usr/local/bin/jq" ] && [ ! -f "/opt/homebrew/bin/jq" ]; then
  echo "Error: 'jq' command-line json processor utility not found."
  echo "NOTE: This script uses the 'jq' command-line json processor utility for formatting the output returned by the AWS CLI."
  echo "      For more information, visit: https://github.com/stedolan/jq/releases/"
fi

# print comment line with date. --------------------------------------------------------------------
# get current date.
curdate=$(date +"%d %b %Y")
echo "# CentOS 7.9 AMI Image IDs as of: ${curdate}."

# loop for each aws region. ------------------------------------------------------------------------
# initialize aws regions for asia pacific, north america, and europe.
aws_region_ids_array=( "ap-south-1" "ap-southeast-1" "ap-southeast-2" "ca-central-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-west-3" "sa-east-1" "us-east-1" "us-east-2" "us-west-1" "us-west-2" )
aws_region_names_array=( "Mumbai" "Singapore" "Sydney" "Central" "Frankfurt" "Ireland" "London" "Paris" "São Paulo" "N. Virginia" "Ohio" "N. California" "Oregon" )

# initialize array index.
ii=0
for aws_region in "${aws_region_ids_array[@]}"; do
  # retrieve ami source image id.
  aws_ami_source=$(aws --region=${aws_region} ec2 describe-images --owners aws-marketplace --filters 'Name=name,Values=CentOS-7-2111*' 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')
# aws_ami_source=$(aws --region=${aws_region} ec2 describe-images --owners aws-marketplace --filters 'Name=product-code,Values=aw0evgkw8e5c1q413zgy5pjce' 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')
  echo "#aws_ami_source=\"${aws_ami_source}\"     # CentOS 7.9 AMI (HVM), SSD Volume Type: ${aws_region} [${aws_region_names_array[$ii]}]"

  # increment array index.
  ii=$(($ii + 1))
done

echo "#export aws_ami_source"

# output will look like the following: -------------------------------------------------------------
# CentOS 7.9 AMI Image IDs as of: 14 Nov 2022.
#aws_ami_source="ami-0763cf792771fe1bd"     # CentOS 7.9 AMI (HVM), SSD Volume Type: ap-south-1 [Mumbai]
#aws_ami_source="ami-00d785f1c099d5a0e"     # CentOS 7.9 AMI (HVM), SSD Volume Type: ap-southeast-1 [Singapore]
#aws_ami_source="ami-0cf5f53cea16d8cbf"     # CentOS 7.9 AMI (HVM), SSD Volume Type: ap-southeast-2 [Sydney]
#aws_ami_source="ami-0ca3e32c623d61bdf"     # CentOS 7.9 AMI (HVM), SSD Volume Type: ca-central-1 [Central]
#aws_ami_source="ami-0b4c74d41ee4bed78"     # CentOS 7.9 AMI (HVM), SSD Volume Type: eu-central-1 [Frankfurt]
#aws_ami_source="ami-0c1f3a8058fde8814"     # CentOS 7.9 AMI (HVM), SSD Volume Type: eu-west-1 [Ireland]
#aws_ami_source="ami-036e229aa5fa198ba"     # CentOS 7.9 AMI (HVM), SSD Volume Type: eu-west-2 [London]
#aws_ami_source="ami-0eb3117f2ccc34ba6"     # CentOS 7.9 AMI (HVM), SSD Volume Type: eu-west-3 [Paris]
#aws_ami_source="ami-04384c010169ed8d3"     # CentOS 7.9 AMI (HVM), SSD Volume Type: sa-east-1 [São Paulo]
#aws_ami_source="ami-002070d43b0a4f171"     # CentOS 7.9 AMI (HVM), SSD Volume Type: us-east-1 [N. Virginia]
#aws_ami_source="ami-05a36e1502605b4aa"     # CentOS 7.9 AMI (HVM), SSD Volume Type: us-east-2 [Ohio]
#aws_ami_source="ami-0dee0f906cf114191"     # CentOS 7.9 AMI (HVM), SSD Volume Type: us-west-1 [N. California]
#aws_ami_source="ami-08c191625cfb7ee61"     # CentOS 7.9 AMI (HVM), SSD Volume Type: us-west-2 [Oregon]
#export aws_ami_source
