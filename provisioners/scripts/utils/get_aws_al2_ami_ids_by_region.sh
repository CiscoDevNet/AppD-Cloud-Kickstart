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
# initialize aws regions for asia pacific, north america, and europe.
aws_region_ids_array=( "ap-south-1" "ap-southeast-1" "ap-southeast-2" "ca-central-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-west-3" "sa-east-1" "us-east-1" "us-east-2" "us-west-1" "us-west-2" )
aws_region_names_array=( "Mumbai" "Singapore" "Sydney" "Central" "Frankfurt" "Ireland" "London" "Paris" "São Paulo" "N. Virginia" "Ohio" "N. California" "Oregon" )

# initialize array index.
ii=0
for aws_region in "${aws_region_ids_array[@]}"; do
  # retrieve ami source image id.
  aws_ami_source=$(aws --region=${aws_region} ec2 describe-images --owners amazon --filters 'Name=name,Values=*amzn2-ami-hvm-2.0.*-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')
  echo "#aws_ami_source=\"${aws_ami_source}\"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: ${aws_region} [${aws_region_names_array[$ii]}]"

  # increment array index.
  ii=$(($ii + 1))
done

echo "#export aws_ami_source"

# output will look like the following: -------------------------------------------------------------
# AWS AL2 AMI Image IDs as of: 14 Nov 2022.
#aws_ami_source="ami-01f703c132f2b1a20"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: ap-south-1 [Mumbai]
#aws_ami_source="ami-0d46390da1dfb8792"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: ap-southeast-1 [Singapore]
#aws_ami_source="ami-02b86aca723e9967e"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: ap-southeast-2 [Sydney]
#aws_ami_source="ami-05926d68079b85f1c"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: ca-central-1 [Central]
#aws_ami_source="ami-0b920b0594b5288fb"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: eu-central-1 [Frankfurt]
#aws_ami_source="ami-0dcc20d3a15abf9bb"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: eu-west-1 [Ireland]
#aws_ami_source="ami-060c0d1361bbd1bd7"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: eu-west-2 [London]
#aws_ami_source="ami-0a53f4992623d6f03"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: eu-west-3 [Paris]
#aws_ami_source="ami-02e0498e7e54ef3c9"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: sa-east-1 [São Paulo]
#aws_ami_source="ami-0c4e4b4eb2e11d1d4"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: us-east-1 [N. Virginia]
#aws_ami_source="ami-07693758d0ebc2111"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: us-east-2 [Ohio]
#aws_ami_source="ami-061352bb71c4724b2"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: us-west-1 [N. California]
#aws_ami_source="ami-0f9f005c313373218"     # Amazon Linux 2 AMI (HVM), SSD Volume Type: us-west-2 [Oregon]
#export aws_ami_source
