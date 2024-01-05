# Providers ----------------------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

# Locals -------------------------------------------------------------------------------------------
locals {
  # format current date for convenience.
  current_date = formatdate("YYYY-MM-DD", timestamp())

  # create range of formatted lab numbers.
  lab_for_each = toset([ for i in range(var.lab_start_number, var.lab_count + var.lab_start_number) : format("%02d", i) ])

  # create vm ssh ingress cidr block list without duplicates.
  vm_ssh_ingress_cidr_blocks = join(",", distinct(tolist([var.aws_ssh_ingress_cidr_blocks, var.cisco_ssh_ingress_cidr_blocks, var.aws_cloud9_ssh_ingress_cidr_blocks, var.aws_ec2_instance_connect_ssh_ingress_cidr_blocks])))

  # define resource names here to ensure standardized naming conventions.
  vpc_name                  = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-VPC"
  security_group_name       = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-Security-Group"
  ec2_access_role_name      = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-EC2-Access-Role"
  ec2_access_policy_name    = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-EC2-Access-Policy"
  ec2_instance_profile_name = "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-EC2-Instance-Profile"

  # define resource tagging here to ensure standardized naming conventions.
  # lpad tag names for aws resources.
  lpad_resource_tags = {
    EnvironmentHome = var.resource_environment_home_tag
    Owner           = var.resource_owner_tag
    Event           = var.resource_event_tag
    Project         = var.resource_project_tag
    Date            = local.current_date
  }

  # appdynamics tag names for aws resources.
  appd_resource_tags = {
    ResourceOwner         = var.resource_owner_email_tag
    CiscoMailAlias        = var.resource_owner_email_tag
    JIRAProject           = "NA"
    DataClassification    = "Cisco Public"
    JIRACreation          = "NA"
    SecurityReview        = "NA"
    Exception             = "NA"
    Environment           = "NonProd"
    DeploymentEnvironment = "NonProd"
    DataTaxonomy          = "Cisco Operations Data"
    CreatedBy             = data.aws_caller_identity.current.arn
    IntendedPublic        = "True"
    ContainsPII           = "False"
    Service               = "CloudKickstartLab"
    ApplicationName       = var.resource_project_tag
    CostCenter            = var.resource_cost_center_tag
  }

  # merge 'lpad_resource_tags' and 'appd_resource_tags' into one set.
  resource_tags = merge(local.lpad_resource_tags, local.appd_resource_tags)
}

# Data Sources -------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {
}

data "aws_availability_zones" "available" {
}

data "aws_ami" "lpad_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.aws_ec2_source_ami_filter]
  }
}

# Modules ------------------------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.4"

  name = local.vpc_name
  cidr = var.aws_vpc_cidr_block

  azs            = data.aws_availability_zones.available.names
  public_subnets = var.aws_vpc_public_subnets

  enable_nat_gateway         = false
  enable_vpn_gateway         = false
  enable_dns_hostnames       = true
  enable_dns_support         = true
  manage_default_network_acl = false
  map_public_ip_on_launch    = true

  tags = local.resource_tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.1"

  name        = local.security_group_name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id
  tags        = local.resource_tags

  ingress_cidr_blocks               = ["0.0.0.0/0"]
  ingress_rules                     = ["http-80-tcp", "http-8080-tcp", "https-443-tcp"]
  egress_rules                      = ["all-all"]
  ingress_with_self                 = [{rule = "all-all"}]
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH port"
      cidr_blocks = local.vm_ssh_ingress_cidr_blocks
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1
}

module "lpad_vm" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 5.6"

  for_each = local.lab_for_each

  name                 = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.resource_name_prefix}-${each.key}-${lower(random_string.suffix.result)}-VM" : "${var.resource_name_prefix}-${lower(random_string.suffix.result)}-VM"
  ami                  = data.aws_ami.lpad_ami.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = var.aws_ec2_ssh_pub_key_name
  tags                 = local.resource_tags

  capacity_reservation_specification = {
    capacity_reservation_preference = "none"
#   capacity_reservation_preference = "open"
  }

  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name           = var.aws_ec2_user_name,
    aws_ec2_hostname            = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.aws_ec2_lpad_vm_hostname_prefix}-${each.key}-vm" : "${var.aws_ec2_lpad_vm_hostname_prefix}-vm"
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = var.lab_use_num_suffix
  }))
}

# Resources ----------------------------------------------------------------------------------------
resource "random_string" "suffix" {
  length  = 5
  special = false
}

resource "aws_iam_role" "ec2_access_role" {
  name               = local.ec2_access_role_name
  assume_role_policy = file("${path.module}/policies/ec2-assume-role-policy.json")
  tags               = local.resource_tags
}

resource "aws_iam_role_policy" "ec2_access_policy" {
  name   = local.ec2_access_policy_name
  role   = aws_iam_role.ec2_access_role.id
  policy = templatefile("${path.module}/policies/ec2-access-policy-template.json", {
    aws_region_name   = var.aws_region
    aws_account_id    = data.aws_caller_identity.current.account_id
    aws_ec2_user_name = var.aws_ec2_user_name
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = local.ec2_instance_profile_name
  role = aws_iam_role.ec2_access_role.name
}

# create ansible trigger to generate inventory and helper files. -----------------------------------
resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when any ec2 instance requires re-provisioning.
  triggers = {
    ec2_instance_ids = join(",", flatten([for vm in module.lpad_vm : vm.id]))
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible aws hosts inventory.
  provisioner "local-exec" {
    working_dir = "."
    command     = <<EOD
cat <<EOF > aws_hosts.inventory
[lpad_vm]
${join("\n", flatten([for vm in module.lpad_vm : vm.public_dns]))}
EOF
EOD
  }
}
