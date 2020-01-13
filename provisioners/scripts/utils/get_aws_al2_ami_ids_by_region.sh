#!/bin/sh
# get the latest aws source ami id's for amazon linux 2 in each region. (currently supports north america and europe.)
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
echo "# AWS AL2 AMI Image IDs as of: ${curdate}."

# loop for each aws region. ------------------------------------------------------------------------
# initialize aws regions for north america and europe.
aws_region_ids_array=( "ap-southeast-2" "ca-central-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-west-3" "us-east-1" "us-east-2" "us-west-1" "us-west-2" )
aws_region_names_array=( "Sydney" "Central" "Frankfurt" "Ireland" "London" "Paris" "N. Virginia" "Ohio" "N. California" "Oregon" )

# initialize array index.
ii=0
for aws_region in "${aws_region_ids_array[@]}"; do
  # retrieve ami source image id.
  aws_ami_source=$(aws --region=${aws_region} ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.*-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')
  echo "#aws_ami_source=\"${aws_ami_source}\"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: ${aws_region} [${aws_region_names_array[$ii]}]"

  # increment array index.
  ii=$(($ii + 1))
done

echo "#export aws_ami_source"

# output will look like the following: -------------------------------------------------------------
# AWS AL2 AMI Image IDs as of: 13 Jan 2020.
#aws_ami_source="ami-0b8b10b5bf11f3a22"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: ap-southeast-2 [Sydney]
#aws_ami_source="ami-0a269ca7cc3e3beff"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: ca-central-1 [Central]
#aws_ami_source="ami-07cda0db070313c52"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: eu-central-1 [Frankfurt]
#aws_ami_source="ami-0713f98de93617bb4"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: eu-west-1 [Ireland]
#aws_ami_source="ami-0089b31e09ac3fffc"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: eu-west-2 [London]
#aws_ami_source="ami-007fae589fdf6e955"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: eu-west-3 [Paris]
#aws_ami_source="ami-062f7200baf2fa504"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: us-east-1 [N. Virginia]
#aws_ami_source="ami-02ccb28830b645a41"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: us-east-2 [Ohio]
#aws_ami_source="ami-03caa3f860895f82e"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: us-west-1 [N. California]
#aws_ami_source="ami-04590e7389a6e577c"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: us-west-2 [Oregon]
#export aws_ami_source
