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
aws_region_ids_array=( "ca-central-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-west-3" "us-east-1" "us-east-2" "us-west-1" "us-west-2" )
aws_region_names_array=( "Central" "Frankfurt" "Ireland" "London" "Paris" "N. Virginia" "Ohio" "N. California" "Oregon" )

# initialize array index.
ii=0
for aws_region in "${aws_region_ids_array[@]}"; do
  # retrieve ami source image id.
  aws_ami_source=$(aws --region=${aws_region} ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')
  echo "#aws_ami_source=\"${aws_ami_source}\"     # Amazon Linux AMI (HVM), SSD Volume Type: ${aws_region} [${aws_region_names_array[$ii]}]"

  # increment array index.
  ii=$(($ii + 1))
done

echo "#export aws_ami_source"

# output will look like the following: -------------------------------------------------------------
# AWS AL2 AMI Image IDs as of: 02 May 2019.
#aws_ami_source="ami-03338e1f67dae0168"     # Amazon Linux AMI (HVM), SSD Volume Type: ca-central-1 [Central]
#aws_ami_source="ami-09def150731bdbcc2"     # Amazon Linux AMI (HVM), SSD Volume Type: eu-central-1 [Frankfurt]
#aws_ami_source="ami-07683a44e80cd32c5"     # Amazon Linux AMI (HVM), SSD Volume Type: eu-west-1 [Ireland]
#aws_ami_source="ami-09ead922c1dad67e4"     # Amazon Linux AMI (HVM), SSD Volume Type: eu-west-2 [London]
#aws_ami_source="ami-0451ae4fd8dd178f7"     # Amazon Linux AMI (HVM), SSD Volume Type: eu-west-3 [Paris]
#aws_ami_source="ami-0de53d8956e8dcf80"     # Amazon Linux AMI (HVM), SSD Volume Type: us-east-1 [N. Virginia]
#aws_ami_source="ami-02bcbb802e03574ba"     # Amazon Linux AMI (HVM), SSD Volume Type: us-east-2 [Ohio]
#aws_ami_source="ami-0019ef04ac50be30f"     # Amazon Linux AMI (HVM), SSD Volume Type: us-west-1 [N. California]
#aws_ami_source="ami-061392db613a6357b"     # Amazon Linux AMI (HVM), SSD Volume Type: us-west-2 [Oregon]
#export aws_ami_source
