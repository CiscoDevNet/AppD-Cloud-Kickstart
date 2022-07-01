# Outputs ------------------------------------------------------------------------------------------
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

output "public_ips" {
  description = "List of public IP addresses assigned to the instances."
  value       = flatten([for vm in module.teastore_vm : vm.public_ip])
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances."
  value       = flatten([for vm in module.teastore_vm : vm.public_dns])
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

output "resource_tags" {
  description = "List of AWS resource tags."
  value       = flatten([for vm in module.teastore_vm : vm.tags_all])
}

output "teastore_urls" {
  description = "List of TeaStore URLs."
  value       = format("%s\n", join("\n", [for dns in tolist([for vm in module.teastore_vm : vm.public_dns]) : format("http://%s:8080/tools.descartes.teastore.webui/", dns)]))
}
