#!/bin/bash
#---------------------------------------------------------------------------------------------------
# Update AWS PoV Playbook1 Cloud9 environment memberships.
#
# AWS Cloud9 is a cloud-based integrated development environment (IDE) that lets you write, run,
# and debug your code with just a browser. It includes a code editor, debugger, and terminal.
# Cloud9 comes prepackaged with essential tools for popular programming languages, including
# JavaScript, Python, PHP, and more, so you don’t need to install files or configure your
# development machine to start new projects.
#
# A shared environment membership is an AWS Cloud9 development environment that multiple users
# have been invited to participate in.
#
# For the PoV Playbook1 labs, this script automates the addition of the PoV Playbook1 lab user as
# well as other AWS account 'admin' users in order to facilitate delivery of the PoV Playbook1 lab
# enablement workshops.
#
# For more details, please visit:
#   https://aws.amazon.com/cloud9/
#   https://docs.aws.amazon.com/cloud9/latest/user-guide/share-environment.html
#
# NOTE: All inputs are defined by external environment variables.
#       Script should be run with installed user privilege (i.e. 'non-root' user).
#       User should have pre-configured AWS CLI and 'jq' command-line JSON processor.
#---------------------------------------------------------------------------------------------------

# set default values for input environment variables if not set. -----------------------------------
# [OPTIONAL] update cloud9 memberships parameters [w/ defaults].
aws_region_name="${aws_region_name:-ap-southeast-1}"
pov_playbook1_name_prefix="${pov_playbook1_name_prefix:-PoV-Playbook1}"

# retrieve list of all cloud9 environments. --------------------------------------------------------
echo "Retrieving list of all Cloud9 environments in AWS '${aws_region_name}' region..."
all_cloud9_envs=$(aws cloud9 --region ${aws_region_name} list-environments --query "environmentIds[*]" | jq -r '.[]')

# check if any cloud9 environments were found.
if [ -z "$all_cloud9_envs" ]; then
  echo "Error: No Cloud9 environments found in AWS '${aws_region_name}' region."
  exit 1
fi

# create array of cloud9 environment ids.
all_cloud9_envs_array=()
all_cloud9_envs_array+=( $all_cloud9_envs )

# print array of all cloud9 environment ids.
#echo "all_cloud9_envs_array(length): ${#all_cloud9_envs_array[@]}"
#for all_cloud9_env_id in "${all_cloud9_envs_array[@]}"; do
#  echo $all_cloud9_env_id
#done
#echo ""

# retrieve metadata for pov playbook1 cloud9 environments. -----------------------------------------
echo "Retrieving metadata for '${pov_playbook1_name_prefix}' Cloud9 environments in '${aws_region_name}'..."

pov_playbook1_cloud9_env_names_array=()
pov_playbook1_cloud9_env_ids_array=()

# loop for each cloud9 environment id,
for all_cloud9_env_id in "${all_cloud9_envs_array[@]}"; do
  # retrieve metadata for pov playbook1 cloud9 environment.
  pov_playbook1_cloud9_env_metadata=$(aws cloud9 --region ${aws_region_name} describe-environments --environment-ids $all_cloud9_env_id --query "environments[*]" | jq -r --arg POV_PLAYBOOK1_NAME_PREFIX "${pov_playbook1_name_prefix}" '[.[] | select(.name | contains($POV_PLAYBOOK1_NAME_PREFIX)) | {name: .name, id: .id}] | sort_by(.name)')

  # check if any pov playbook1 cloud9 environments were found. if not, continue to next environent.
  if [ -z "$(echo $pov_playbook1_cloud9_env_metadata | jq '. | select(length > 0)')" ]; then
    continue
  fi

  # print list of pov playbook1 cloud9 environment metadata.
  echo $pov_playbook1_cloud9_env_metadata | jq '. | select(length > 0)'

  # create array of names for pov playbook1 cloud9 environments.
  pov_playbook1_cloud9_env_names_array+=( $(echo $pov_playbook1_cloud9_env_metadata | jq -r '.[] | .name') )

  # create array of ids for pov playbook1 cloud9 environments.
  pov_playbook1_cloud9_env_ids_array+=( $(echo $pov_playbook1_cloud9_env_metadata | jq -r '.[] | .id') )
done

echo ""

# check if any pov playbook1 cloud9 environment names were found.
if [ "${#pov_playbook1_cloud9_env_names_array[@]}" -lt 1 ]; then
  echo "Error: No '${pov_playbook1_name_prefix}' Cloud9 environments found in AWS '${aws_region_name}' region."
  echo "       Cloud9 environment 'names' array is empty."
  exit 1
fi

# print array of pov playbook1 cloud9 environment names.
#echo "pov_playbook1_cloud9_env_names_array[length]: ${#pov_playbook1_cloud9_env_names_array[@]}"
#for pov_playbook1_cloud9_env_name in "${pov_playbook1_cloud9_env_names_array[@]}"; do
#  echo $pov_playbook1_cloud9_env_name
#done
#echo ""

# check if any pov playbook1 cloud9 environment ids were found.
if [ "${#pov_playbook1_cloud9_env_ids_array[@]}" -lt 1 ]; then
  echo "Error: No '${pov_playbook1_name_prefix}' Cloud9 environments found in AWS '${aws_region_name}' region."
  echo "       Cloud9 environment 'ids' array is empty."
  exit 1
fi

# print array of pov playbook1 cloud9 environment ids.
#echo "pov_playbook1_cloud9_env_ids_array[length]: ${#pov_playbook1_cloud9_env_ids_array[@]}"
#for pov_playbook1_cloud9_env_id in "${pov_playbook1_cloud9_env_ids_array[@]}"; do
#  echo $pov_playbook1_cloud9_env_id
#done
#echo ""

# retrieve current aws account id. -----------------------------------------------------------------
echo "Retrieving current AWS Account ID..."
aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)

# check if aws account id was found.
if [ -z "$aws_account_id" ]; then
  echo "Error: AWS Account ID not found."
  exit 1
fi

# print aws account id.
echo "AWS Account ID: '${aws_account_id}'"
echo ""

# create array of user arns to add to cloud9 environment memberships. ------------------------------
# NOTE: cloud9 supports a maximum of 7 shared memberships plus the owner.
echo "Creating array of User ARNs to add to Cloud9 memberships..."
pov_playbook1_cloud9_user_share_array=()

# create user arns array for appd cisco runon aws account.
if [ "${aws_account_id}" == "395719258032" ]; then
  pov_playbook1_cloud9_user_share_array+=( "arn:aws:iam::395719258032:user/pov-playbook-lab-user-01" )
  pov_playbook1_cloud9_user_share_array+=( "arn:aws:iam::395719258032:user/ed.barberis" )
  pov_playbook1_cloud9_user_share_array+=( "arn:aws:iam::395719258032:user/james.schneider" )
else
  echo "Error: aws_account_id: IAM users undefined for AWS Account: '${aws_account_id}'."
  exit 1
fi

# print user arns array.
echo "User ARNs:"
for pov_playbook1_cloud9_user_arn in "${pov_playbook1_cloud9_user_share_array[@]}"; do
  echo $pov_playbook1_cloud9_user_arn
done
echo ""

# check to make sure we don't have more than 7 users in the array.
if [ "${#pov_playbook1_cloud9_user_share_array[@]}" -gt 7 ]; then
  echo "Error: You cannot invite more than 7 members to your environment (8 total-including the owner)."
  exit 1
fi

# add user arns to cloud9 environment membership. --------------------------------------------------
# loop for each user arn,
for pov_playbook1_cloud9_user_arn in "${pov_playbook1_cloud9_user_share_array[@]}"; do
  # initialize array index.
  ii=0

  # loop for each pov playbook1 cloud9 environment arn,
  for pov_playbook1_cloud9_env_id in "${pov_playbook1_cloud9_env_ids_array[@]}"; do
    # retrieve pov playbook1 cloud9 metadata filtered by user arn.
    echo "Checking for user: '${pov_playbook1_cloud9_user_arn}' in Cloud9 environment: '${pov_playbook1_cloud9_env_names_array[$ii]}..."
    pov_playbook1_cloud9_member_metadata=$(aws cloud9 --region ${aws_region_name} describe-environment-memberships --environment-id $pov_playbook1_cloud9_env_id --query "memberships[*]" | jq -r --arg USER_ARN "${pov_playbook1_cloud9_user_arn}" '[.[] | select(.userArn | contains($USER_ARN)) | {userArn: .userArn, permissions: .permissions}] | sort_by(.name)')

    # is user arn is already a member of the cloud9 environment?
    if [ -z "$(echo $pov_playbook1_cloud9_member_metadata | jq '. | select(length > 0)')" ]; then
      echo "Adding user: '${pov_playbook1_cloud9_user_arn}' to Cloud9 environment: '${pov_playbook1_cloud9_env_names_array[$ii]}..."
      aws cloud9 --region ${aws_region_name} create-environment-membership --environment-id $pov_playbook1_cloud9_env_id --user-arn $pov_playbook1_cloud9_user_arn --permissions read-write | jq '.'
      echo ""
    fi

    # increment array index.
    ii=$(($ii + 1))
  done
done
echo ""

# print completion message. ------------------------------------------------------------------------
echo "Update '${pov_playbook1_name_prefix}' Cloud9 environments in '${aws_region_name}' operation complete."
