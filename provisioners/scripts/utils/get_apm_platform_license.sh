#!/bin/sh -eux
#---------------------------------------------------------------------------------------------------
# Get AppDynamics on-premises trial license.
#
# If you are using AppDynamics on-premises, you must manually apply the license file after
# installing the Controller. Whenever you purchase additional units, you must update the license
# file. If you are updating Application Analytics licenses in an on-premises environment, you may
# have to do some of the updates manually, once you have updated your Controller license.
#
# For more details, please visit:
#   https://docs.appdynamics.com/display/PRO45/Applying+or+Updating+a+License+File
#
# For project administrators, the license is maintained via an AWS S3 bucket. Here are two
# sample AWS CLI commands to upload or delete the license file:
#   aws s3 cp license-apm-any-language-expires-2020-07-01.lic s3://appd-cloud-kickstart-tools/apm-platform/ --acl public-read
#   aws s3 rm s3://appd-cloud-kickstart-tools/apm-platform/license-apm-any-language-expires-2020-07-01.lic
#
# NOTE: Script should be run with 'root' privilege.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] appdynamics platform license parameters [w/ defaults].
appd_home="${appd_home:-/opt/appdynamics}"
appd_platform_home="${appd_platform_home:-platform}"
appd_license_expiration="${appd_license_expiration:-2020-07-01}"
appd_license_install="${appd_license_install:-false}"

# download the apm platform license. ---------------------------------------------------------------
appd_s3_bucket_folder="appd-cloud-kickstart-tools/apm-platform"
appd_apm_license_file="license-apm-any-language-expires-${appd_license_expiration}.lic"

rm -f ${appd_apm_license_file}
aws s3 cp  s3://${appd_s3_bucket_folder}/${appd_apm_license_file} .

# public access url (deprecated).
#appd_s3_bucket_folder="appd-cloud-kickstart-tools.s3.us-east-2.amazonaws.com/apm-platform"
#curl --silent --remote-name https://${appd_s3_bucket_folder}/${appd_apm_license_file} --output ${appd_apm_license_file}

# install license file. ----------------------------------------------------------------------------
appd_controller_folder="${appd_home}/${appd_platform_home}/product/controller"

if [ "$appd_license_install" == "true" ]; then
  cp ${appd_apm_license_file} ${appd_controller_folder}/license.lic
fi
