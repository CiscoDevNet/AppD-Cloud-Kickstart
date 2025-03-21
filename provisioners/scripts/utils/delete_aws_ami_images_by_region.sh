#!/bin/bash
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
appd_project_image_types="${appd_project_image_types-APM-Platform-AL2 APM-Platform-AL2023 APM-Platform-CentOS7 APM-Platform-CentOS8-Stream APM-Platform-Ubuntu-Jammy CWOM-Platform-CentOS7 DEVNET-CentOS7 EXT-AL2 EXT-AL2023 EXT-CentOS7 EXT-Ubuntu-Jammy LPAD-AlmaLinux8 LPAD-AlmaLinux9 LPAD-AL2 LPAD-AL2023 LPAD-CentOS7 LPAD-CentOS8-Stream LPAD-CentOS9-Stream LPAD-Fedora37 LPAD-Fedora38 LPAD-Fedora39 KonaKart-LPAD-Ubuntu-Jammy LPAD-OracleLinux7 LPAD-OracleLinux8 LPAD-OracleLinux9 LPAD-Rocky8 LPAD-Rocky9 LPAD-Ubuntu-Bionic LPAD-Ubuntu-Focal LPAD-Ubuntu-Jammy LPAD-Ubuntu-Lunar LPAD-Ubuntu-Mantic LPAD-Ubuntu-Noble LPAD-Ubuntu-Oracular K8S-CentOS7 PoV-Playbook1-AL2 PoV-Playbook1-AL2023 PoV-Playbook1-CentOS7 PoV-Playbook1-Ubuntu-Bionic PoV-Playbook1-Ubuntu-Focal PoV-Playbook1-Ubuntu-Jammy TeaStore-CentOS7}"
aws_ami_region="${aws_ami_region-us-east-1}"
aws_ami_keep_last="${aws_ami_keep_last-true}"

# check if 'jq' is installed. ----------------------------------------------------------------------
if [ ! -f "/usr/local/bin/jq" ] && [ ! -f "/opt/homebrew/bin/jq" ]; then
  echo "Error: 'jq' command-line json processor utility not found."
  echo "NOTE: This script uses the 'jq' command-line json processor utility for formatting the output"
  echo "      returned by the AWS CLI."
  echo "      For more information, visit: https://github.com/stedolan/jq/releases/"
  exit 1
fi

# delete the project-specific aws ami's for the specified region. ----------------------------------
# initialize project image types array.
appd_project_image_types_array=( ${appd_project_image_types} )
appd_project_image_types_array_length=${#appd_project_image_types_array[@]}

# loop for each project image type.
for image_type in "${appd_project_image_types_array[@]}"; do
  # retrieve ami image data.
  ami_image_data=$(aws ec2 describe-images --region ${aws_ami_region} --filters "Name=tag:Project,Values=${appd_platform_name}" "Name=tag:Project_Image_Type,Values=${image_type}" --output json | jq '[.Images[] | {Name: .Name, ImageId: .ImageId, SnapshotId: .BlockDeviceMappings[0].Ebs.SnapshotId, CreationDate: .CreationDate}] | sort_by(.CreationDate)')

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
