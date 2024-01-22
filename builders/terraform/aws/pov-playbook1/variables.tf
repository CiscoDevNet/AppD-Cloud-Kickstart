# Variables ----------------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "aws_vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_vpc_public_subnets" {
  description = "A list of public subnets inside the VPC."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic external to AWS."
  type        = string
  default     = "0.0.0.0/0"
}

variable "cisco_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic from Cisco networks."
  type        = string
  default     = "128.107.241.0/24,72.163.220.53/32,209.234.175.138/32,173.38.208.173/32,173.38.220.54/32,72.163.220.0/24,173.39.121.0/24"
}

# Ingress CIDR block IP ranges for 'CLOUD9' service in ["us-east-1", "us-east-2", "us-west-1", "us-west-2"].
variable "aws_cloud9_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic from AWS Cloud9 System Manager."
  type        = string
  default     = "35.172.155.192/27,35.172.155.96/27,18.188.9.0/27,18.188.9.32/27,13.52.232.224/27,18.144.158.0/27,34.217.141.224/27,34.218.119.32/27,18.184.138.224/27,18.184.203.128/27,3.10.127.32/27,3.10.201.64/27,13.250.186.128/27,13.250.186.160/27"
}

# Ingress CIDR block IP ranges for 'EC2_INSTANCE_CONNECT' service in ["us-east-1", "us-east-2", "us-west-1", "us-west-2"].
variable "aws_ec2_instance_connect_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic from AWS EC2 Instance Connect."
  type        = string
  default     = "18.206.107.24/29,3.16.146.0/29,13.52.6.112/29,18.237.140.160/29,3.120.181.40/29,3.8.37.24/29,3.0.5.32/29"
}

variable "aws_ec2_pov_playbook1_vm_hostname_prefix" {
  description = "AWS EC2 PoV Playbook1 VM hostname prefix."
  type        = string
  default     = "pov-pb1"
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
  default     = "PoV-Playbook1-AL2-AMI-*"
# default     = "PoV-Playbook1-CentOS79-AMI-*"
}

variable "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "t3.large"
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
  default     = "PoV-Playbook1"
}

variable "resource_environment_home_tag" {
  description = "Resource environment home tag."
  type        = string
  default     = "AppDynamics PoV Playbook1 Workshop"
}

variable "resource_owner_tag" {
  description = "Resource owner tag."
  type        = string
  default     = "AppDynamics Cloud Channel Sales Teams"
}

variable "resource_event_tag" {
  description = "Resource event tag."
  type        = string
  default     = "AppDynamics Cloud Kickstart Workshop"
}

variable "resource_project_tag" {
  description = "Resource project tag."
  type        = string
  default     = "AppDynamics Cloud Kickstart"
}

variable "resource_owner_email_tag" {
  description = "Resource owner email tag."
  type        = string
  default     = "ed.barberis@appdynamics.com"
}

variable "resource_cost_center_tag" {
  description = "Resource cost center tag."
  type        = string
  default     = "020430800"
}
