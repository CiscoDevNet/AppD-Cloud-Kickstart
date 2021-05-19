# Providers ----------------------------------------------------------------------------------------
provider "aws" {
  region  = var.aws_region
}

# Locals -------------------------------------------------------------------------------------------
locals {
  current_date = formatdate("YYYY-MM-DD", timestamp())
}

# Data Sources -------------------------------------------------------------------------------------
# data sources to get ami details.
data "aws_ami" "teastore-centos79" {
  most_recent = true
  owners      = ["self"]

  filter {
    name = "name"
    values = [var.aws_ec2_source_ami_filter]
  }
}

# Modules ------------------------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.0"

  name = "VPC-${var.resource_name_prefix}-${local.current_date}"
  cidr = var.aws_vpc_cidr

  azs             = var.aws_availability_zones
  public_subnets  = var.aws_vpc_public_subnets
  private_subnets = var.aws_vpc_private_subnets

  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.resource_tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 4.0"

  name        = "SG-${var.resource_name_prefix}-${local.current_date}"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id
  tags        = var.resource_tags

  ingress_cidr_blocks               = ["0.0.0.0/0"]
  ingress_rules                     = ["http-80-tcp", "http-8080-tcp", "https-443-tcp", "mysql-tcp"]
  egress_rules                      = ["all-all"]
  ingress_with_self                 = [{rule = "all-all"}]
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH port"
      cidr_blocks = var.aws_ssh_ingress_cidr_blocks
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 1
}

module "teastore_vm" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.19"

  instance_count = 1
  num_suffix_format = "-%02d"
  use_num_suffix = true

  name                 = "${var.resource_name_prefix}-VM-${local.current_date}-Node"
  ami                  = data.aws_ami.teastore-centos79.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"
  tags                 = var.resource_tags

  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name           = var.aws_ec2_user_name,
    aws_ec2_hostname_prefix     = var.aws_ec2_teastore_vm_hostname_prefix,
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = "false"
  }))
}

# Resources ----------------------------------------------------------------------------------------
resource "aws_iam_role" "ec2_access_role" {
  name               = "EC2-Access-Role-${var.resource_name_prefix}-${local.current_date}"
  assume_role_policy = file("${path.module}/policies/ec2-assume-role-policy.json")
  tags               = var.resource_tags
}

resource "aws_iam_role_policy" "ec2_access_policy" {
  name   = "EC2-Access-Policy-${var.resource_name_prefix}-${local.current_date}"
  role   = aws_iam_role.ec2_access_role.id
  policy = file("${path.module}/policies/ec2-access-policy.json")
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
# name = "EC2-Instance-Profile-${var.resource_name_prefix}-${local.current_date}"
  role = aws_iam_role.ec2_access_role.name
}

resource "local_file" "private_ip_file" {
  filename = "private-ip-file.txt"
  content  = format("%s\n", join("\n", toset(module.teastore_vm.private_ip)))
  file_permission = "0644"
}

resource "local_file" "public_ip_file" {
  filename = "public-ip-file.txt"
  content  = format("%s\n", join("\n", toset(module.teastore_vm.public_ip)))
  file_permission = "0644"
}
