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

data "aws_ami" "apm_platform_al2" {
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
  version = ">= 5.2"

  name = "VPC-${var.resource_name_prefix}-${local.current_date}"
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

  name        = "SG-${var.resource_name_prefix}-${local.current_date}"
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
    },
    {
      from_port   = 9191
      to_port     = 9191
      protocol    = "tcp"
      description = "AppDynamics Enterprise Console HTTP port"
      cidr_blocks = var.aws_ssh_ingress_cidr_blocks
    },
    {
      from_port   = 8090
      to_port     = 8090
      protocol    = "tcp"
      description = "AppDynamics Controller HTTP port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8181
      to_port     = 8181
      protocol    = "tcp"
      description = "AppDynamics Controller HTTPS port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9080
      to_port     = 9081
      protocol    = "tcp"
      description = "AppDynamics Events Service HTTP ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 7001
      to_port     = 7002
      protocol    = "tcp"
      description = "AppDynamics EUM Server HTTP/HTTPS ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 6
}

module "apm_platform_vm" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 5.5"

  for_each = local.lab_for_each

  name                 = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.resource_name_prefix}-${each.key}-VM-${local.current_date}" : "${var.resource_name_prefix}-VM-${local.current_date}"
  ami                  = data.aws_ami.apm_platform_al2.id
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
    aws_ec2_hostname            = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.aws_ec2_apm_platform_vm_hostname_prefix}-${each.key}-vm" : "${var.aws_ec2_apm_platform_vm_hostname_prefix}-vm"
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = var.lab_use_num_suffix
  }))
}

# Resources ----------------------------------------------------------------------------------------
resource "aws_iam_role" "ec2_access_role" {
  name               = "EC2-Access-Role-${var.resource_name_prefix}-${local.current_date}"
  assume_role_policy = file("${path.module}/policies/ec2-assume-role-policy.json")
  tags               = local.resource_tags
}

resource "aws_iam_role_policy" "ec2_access_policy" {
  name   = "EC2-Access-Policy-${var.resource_name_prefix}-${local.current_date}"
  role   = aws_iam_role.ec2_access_role.id
  policy = templatefile("${path.module}/policies/ec2-access-policy-template.json", {
    aws_region_name   = var.aws_region
    aws_account_id    = data.aws_caller_identity.current.account_id
    aws_ec2_user_name = var.aws_ec2_user_name
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2-Instance-Profile-${var.resource_name_prefix}-${local.current_date}"
  role = aws_iam_role.ec2_access_role.name
}

resource "local_file" "enterprise_console_urls_file" {
  filename = "enterprise-console-urls.txt"
  content  = format("%s\n", join("\n", [for dns in tolist([for vm in module.apm_platform_vm : vm.public_dns]) : format("http://%s:9191/index.html", dns)]))
  file_permission = "0644"
}

resource "local_file" "controller_urls_file" {
  filename = "controller-urls.txt"
  content  = format("%s\n", join("\n", [for dns in tolist([for vm in module.apm_platform_vm : vm.public_dns]) : format("http://%s:8090/controller/", dns)]))
  file_permission = "0644"
}

# create ansible trigger to generate inventory and helper files. -----------------------------------
resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when any ec2 instance requires re-provisioning.
  triggers = {
    ec2_instance_ids = join(",", flatten([for vm in module.apm_platform_vm : vm.id]))
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible aws hosts inventory.
  provisioner "local-exec" {
    working_dir = "."
    command     = <<EOD
cat <<EOF > aws_hosts.inventory
[apm_platform_vm]
${join("\n", flatten([for vm in module.apm_platform_vm : vm.public_dns]))}
EOF
EOD
  }
}
