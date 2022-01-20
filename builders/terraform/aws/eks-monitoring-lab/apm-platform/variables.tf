# Variables ----------------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "aws_availability_zones" {
  type    = list(string)
  default = ["us-east-2a", "us-east-2b"]
}

variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24"]
# default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_ssh_ingress_cidr_blocks" {
  description = "The computed ingress CIDR blocks for inbound ssh traffic"
  type        = string
  default     = "0.0.0.0/0,10.0.1.0/24"
# default     = "0.0.0.0/0,10.0.1.0/24,10.0.2.0/24,10.0.3.0/24,10.0.4.0/24"
}

variable "aws_ec2_apm_platform_vm_hostname_prefix" {
  description = "AWS EC2 APM-Platform VM hostname prefix."
  type        = string
  default     = "apm"
}

variable "aws_ec2_domain" {
  description = "AWS EC2 domain name."
  type        = string
  default     = "localdomain"
}

variable "aws_ec2_user_name" {
  description = "AWS EC2 user name."
  type        = string
  default     = "ec2-user"
# default     = "centos"
}

variable "aws_ec2_ssh_pub_key_name" {
  description = "AWS EC2 SSH public key for Lab VMs."
  type        = string
  default     = "AppD-Cloud-Kickstart"
}

variable "aws_ec2_source_ami_filter" {
  description = "AWS EC2 source AMI disk image filter."
  type        = string
  default     = "APM-Platform-21411-AL2-AMI-*"
# default     = "APM-Platform-21411-CentOS79-AMI-*"
}

variable "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
# default     = "t2.micro"
# default     = "m5a.large"
  default     = "m5a.xlarge"
}

variable "lab_count" {
  description = "Number of Lab environments to launch."
  type        = number
  default     = 1
}

variable "lab_start_number" {
  description = "Starting lab number for incrementally naming resources."
  type        = number
  default     = 1
}

variable "lab_use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1."
  type        = bool
  default     = true
}

variable "resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "APM-Platform"
}

variable "resource_tags" {
  description = "Tag names for AWS resources."
  type = map
  default = {
    "Owner"   = "AppDynamics Cloud Channel Sales Team"
    "Project" = "AppDynamics Cloud Kickstart"
    "Event"   = "AppDynamics Cloud Kickstart Workshop"
  }
}
