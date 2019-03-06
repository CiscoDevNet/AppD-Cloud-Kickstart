#!/bin/sh
#---------------------------------------------------------------------------------------------------
# Delete the AppDynamics Cloud Kickstart project-specific AWS AMI's for the specified region.
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       This script uses the 'jq' command-line json processor utility for formatting the output
#       returned by the AWS CLI.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
appd_platform_name="${appd_platform_name-AppDynamics Cloud Kickstart}"
appd_project_image_types="${appd_project_image_types-APM-Platform EXT LPAD-EKS}"
aws_ami_region="${aws_ami_region-us-west-2}"
aws_ami_keep_last="${aws_ami_keep_last-true}"

# check if 'jq' is installed. ----------------------------------------------------------------------
if [ ! -f "/usr/local/bin/jq" ]; then
  echo "Error: 'jq' command-line json processor utility not found."
  echo "NOTE: This script uses the 'jq' command-line json processor utility for formatting the output"
  echo "      returned by the AWS CLI."
  echo "      For more information, visit: https://github.com/stedolan/jq/releases/"
fi

# delete the project-specific aws ami's for the specified region. ----------------------------------
# initialize project image types array.
appd_project_image_types_array=( ${appd_project_image_types} )
appd_project_image_types_array_length=${#appd_project_image_types_array[@]}

# loop for each project image type.
for image_type in "${appd_project_image_types_array[@]}"; do
  # retrieve ami image data.
  ami_image_data=$(aws ec2 describe-images --region ${aws_ami_region} --filters "Name=tag:Project,Values=${appd_platform_name}, Name=tag:Project_Image_Type,Values=${image_type}" --output json | jq '[.Images[] | {Name: .Name, ImageId: .ImageId, SnapshotId: .BlockDeviceMappings[].Ebs.SnapshotId, CreationDate: .CreationDate}] | sort_by(.CreationDate)')

  # build individual ami image attribute arrays.
  image_name_array=( $(echo "${ami_image_data}" | jq '.' | awk '/Name/ {print $2}') )
  image_id_array=( $(echo "${ami_image_data}" | jq '.' | awk '/ImageId/ {print $2}') )
  snapshot_id_array=( $(echo "${ami_image_data}" | jq '.' | awk '/SnapshotId/ {print $2}') )

  image_array_length=${#image_name_array[@]}

  if [ "$aws_ami_keep_last" == "true" ]; then
    image_array_length=$(($image_array_length - 1))
  fi

  # loop for each project image.
  ii=0
  for image_name in "${image_name_array[@]}"; do
    if [ "$ii" -lt ${image_array_length} ]; then
      image_name=$(echo "Name: ${image_name}" | awk -F '"' '{print $2}')
      image_id=$(echo "ImageId: ${image_id_array[$ii]}" | awk -F '"' '{print $2}')
      snapshot_id=$(echo "SnapshotId: ${snapshot_id_array[$ii]}" | awk -F '"' '{print $2}')

      echo "Deleting AMI image: '${image_name}':"
      echo "  aws ec2 deregister-image --region ${aws_ami_region} --image-id ${image_id}"
      aws ec2 deregister-image --region ${aws_ami_region} --image-id ${image_id}
      echo "  aws ec2 delete-snapshot --region ${aws_ami_region} --snapshot-id ${snapshot_id}"
      aws ec2 delete-snapshot --region ${aws_ami_region} --snapshot-id ${snapshot_id}
    fi

    # increment array index.
    ii=$(($ii + 1))
  done
done
