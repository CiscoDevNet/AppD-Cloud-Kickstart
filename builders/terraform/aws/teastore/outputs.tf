output "aws_region" {
  description = "AWS region."
  value       = var.aws_region
}

output "aws_ec2_teastore_vm_hostname_prefix" {
  description = "AWS EC2 TeaStore VM hostname prefix."
  value       = var.aws_ec2_teastore_vm_hostname_prefix
}

output "aws_ec2_domain" {
  description = "AWS EC2 domain name."
  value       = var.aws_ec2_domain
}

output "aws_ec2_user_name" {
  description = "AWS EC2 user name."
  value       = var.aws_ec2_user_name
}

output "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  value       = var.aws_ec2_instance_type
}

output "ids" {
  description = "List of IDs of instances."
  value       = flatten([toset(module.teastore_vm.id)])
}

output "private_ips" {
  description = "List of private IP addresses assigned to the instances."
  value       = flatten([toset(module.teastore_vm.private_ip)])
}

output "public_ips" {
  description = "List of public IP addresses assigned to the instances."
  value       = flatten([toset(module.teastore_vm.public_ip)])
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances."
  value       = flatten([toset(module.teastore_vm.public_dns)])
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_azs" {
  description = "A list of availability zones specified as arguments to this VPC module."
  value       = module.vpc.azs
}

output "vpc_public_subnet_ids" {
  description = "A list of IDs of public subnets."
  value       = tolist(module.vpc.public_subnets)
}

output "vpc_private_subnet_ids" {
  description = "A list of IDs of private subnets."
  value       = tolist(module.vpc.private_subnets)
}

output "vpc_security_group_ids" {
  description = "List of VPC security group ids assigned to the instances."
  value       = toset(flatten([toset(module.teastore_vm.vpc_security_group_ids)]))
}

output "root_block_device_volume_ids" {
  description = "List of volume IDs of root block devices of instances."
  value       = flatten([toset(module.teastore_vm.root_block_device_volume_ids)])
}

output "resource_tags" {
  description = "List of AWS resource tags."
  value       = module.teastore_vm.tags
}
