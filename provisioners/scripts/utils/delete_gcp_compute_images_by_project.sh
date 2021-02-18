#!/bin/sh
#---------------------------------------------------------------------------------------------------
# Delete the AppDynamics Cloud Kickstart project-specific GCP Compute images for the specified zone.
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       This script uses the 'jq' command-line json processor utility for formatting the output
#       returned by the gcloud CLI.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
appd_project_image_families="${appd_project_image_families-apm-platform-centos79-images apm-platform-ha-centos79-images lpad-centos79-images teastore-centos79-images}"
gcp_image_keep_last="${gcp_image_keep_last-true}"

# check if 'jq' is installed. ----------------------------------------------------------------------
if [ ! -f "/usr/local/bin/jq" ]; then
  echo "Error: 'jq' command-line json processor utility not found."
  echo "NOTE: This script uses the 'jq' command-line json processor utility for formatting the output"
  echo "      returned by the AWS CLI."
  echo "      For more information, visit: https://github.com/stedolan/jq/releases/"
fi

# delete the project-specific gcp compute images for the curent default project. -------------------
# initialize project image families array.
appd_project_image_families_array=( ${appd_project_image_families} )
appd_project_image_families_array_length=${#appd_project_image_families_array[@]}

# loop for each project image family.
for image_family in "${appd_project_image_families_array[@]}"; do
  # retrieve gcp compute image data.
  gcp_image_names=$(gcloud compute images list --filter="family:${image_family}" --format=json | jq -rs '.[] | sort_by(.creationTimestamp) | .[] | {name: .name} | .[] | values')

  # build individual gcp compute image attribute arrays.
  gcp_image_names_array=( $gcp_image_names )
  gcp_image_names_array_length=${#gcp_image_names_array[@]}

  if [ "$gcp_image_keep_last" == "true" ]; then
    gcp_image_names_array_length=$(($gcp_image_names_array_length - 1))
  fi

  # loop for each project image.
  ii=0
  for image_name in "${gcp_image_names_array[@]}"; do
    if [ "$ii" -lt ${gcp_image_names_array_length} ]; then
      echo "Deleting GCP Compute image: '${image_name}':"
      echo "  gcloud compute images delete ${image_name} --quiet"
      gcloud compute images delete ${image_name} --quiet
    fi

    # increment array index.
    ii=$(($ii + 1))
  done
done
