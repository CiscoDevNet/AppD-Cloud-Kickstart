#!/bin/sh
#---------------------------------------------------------------------------------------------------
# Delete the AppDynamics Cloud Kickstart project-specific Azure Images's by resource group.
#
# NOTE: All inputs are defined by external environment variables.
#       Optional variables have reasonable defaults, but you may override as needed.
#       This script uses the 'jq' command-line json processor utility for formatting the output
#       returned by the AWS CLI.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
appd_project_image_types="${appd_project_image_types-APM-Platform LPAD TeaStore}"
azurerm_resource_group_name="${azurerm_resource_group_name-Cloud-Kickstart-Workshop-Images}"
azurerm_image_keep_last="${azurerm_image_keep_last-true}"

# check if 'jq' is installed. ----------------------------------------------------------------------
if [ ! -f "/usr/local/bin/jq" ]; then
  echo "Error: 'jq' command-line json processor utility not found."
  echo "NOTE: This script uses the 'jq' command-line json processor utility for formatting the output"
  echo "      returned by the AWS CLI."
  echo "      For more information, visit: https://github.com/stedolan/jq/releases/"
fi

# delete the project-specific azure images's by resource group. ------------------------------------
# initialize project image types array.
appd_project_image_types_array=( ${appd_project_image_types} )
appd_project_image_types_array_length=${#appd_project_image_types_array[@]}

# loop for each project image type.
for image_type in "${appd_project_image_types_array[@]}"; do
  # retrieve azure image data.
  azurerm_image_names=$(az image list --resource-group ${azurerm_resource_group_name} --query "[?contains(@.name, '${image_type}')==\`true\`]" | jq -rs '.[] | sort_by(.name) | .[] | {name: .name} | .[] | values')
# azurerm_image_ids=$(az image list --resource-group ${azurerm_resource_group_name} --query "[?contains(@.name, '${image_type}')==\`true\`]" | jq -rs '.[] | sort_by(.name) | .[] | {id: .id} | .[] | values')

  # build individual azure vm image attribute arrays.
  azurerm_image_names_array=( $azurerm_image_names )
  azurerm_image_names_array_length=${#azurerm_image_names_array[@]}

  if [ "$azurerm_image_keep_last" == "true" ]; then
    azurerm_image_names_array_length=$(($azurerm_image_names_array_length - 1))
  fi

  # loop for each project image.
  ii=0
  for image_name in "${azurerm_image_names_array[@]}"; do
    if [ "$ii" -lt ${azurerm_image_names_array_length} ]; then
      echo "Deleting Azure image: '${image_name}':"
      echo "  az image delete --resource-group ${azurerm_resource_group_name} --name ${image_name}"
      az image delete --resource-group ${azurerm_resource_group_name} --name ${image_name}
#     echo "  az image delete --ids ${image_id}"
#     az image delete --ids ${image_id}
    fi

    # increment array index.
    ii=$(($ii + 1))
  done
done
