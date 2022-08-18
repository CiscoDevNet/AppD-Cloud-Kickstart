# Providers ----------------------------------------------------------------------------------------
provider "aws" {
  region  = var.aws_region
}

# Locals -------------------------------------------------------------------------------------------
locals {
  current_date = formatdate("YYYY-MM-DD", timestamp())
  lab_for_each = toset([ for i in range(var.lab_start_number, var.lab_count + var.lab_start_number) : format("%02d", i) ])
}

# Data Sources -------------------------------------------------------------------------------------
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
  version = ">= 3.14"

  name = "VPC-${var.resource_name_prefix}-${local.current_date}"
  cidr = var.aws_vpc_cidr

  azs             = var.aws_availability_zones
  public_subnets  = var.aws_vpc_public_subnets

  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.resource_tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 4.11"

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
  version = ">= 4.1"

  for_each = local.lab_for_each

  name                 = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.resource_name_prefix}-${each.key}-VM-${local.current_date}" : "${var.resource_name_prefix}-VM-${local.current_date}"
  ami                  = data.aws_ami.teastore-centos79.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = var.aws_ec2_ssh_pub_key_name
  tags                 = var.resource_tags

  capacity_reservation_specification = {
    capacity_reservation_preference = "none"
#   capacity_reservation_preference = "open"
  }

  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name           = var.aws_ec2_user_name,
    aws_ec2_hostname            = var.lab_count > 1 || var.lab_use_num_suffix ? "${var.aws_ec2_teastore_vm_hostname_prefix}-${each.key}-vm" : "${var.aws_ec2_teastore_vm_hostname_prefix}-vm"
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = var.lab_use_num_suffix
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
  name = "EC2-Instance-Profile-${var.resource_name_prefix}-${local.current_date}"
  role = aws_iam_role.ec2_access_role.name
}

resource "local_file" "teastore_urls_file" {
  filename = "teastore-urls.txt"
  content  = format("%s\n", join("\n", [for dns in tolist([for vm in module.teastore_vm : vm.public_dns]) : format("http://%s:8080/tools.descartes.teastore.webui/", dns)]))
  file_permission = "0644"
}

# create ansible trigger to generate inventory and helper files. -----------------------------------
resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when any ec2 instance requires re-provisioning.
  triggers = {
    ec2_instance_ids = join(",", flatten([for vm in module.teastore_vm : vm.id]))
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible aws hosts inventory.
  provisioner "local-exec" {
    working_dir = "."
    command     = <<EOD
cat <<EOF > aws_hosts.inventory
[teastore_vm]
${join("\n", flatten([for vm in module.teastore_vm : vm.public_dns]))}
EOF
EOD
  }
}
