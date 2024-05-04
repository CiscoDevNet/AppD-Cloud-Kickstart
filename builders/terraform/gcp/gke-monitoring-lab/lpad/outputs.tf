# Outputs ------------------------------------------------------------------------------------------
output "project_id" {
  description = "GCP Project ID."
  value       = var.gcp_project_id
}

output "region" {
  description = "GCP region."
  value       = var.gcp_region
}

output "zone" {
  description = "GCP zone."
  value       = var.gcp_zone
}

output "lpad_vm_hostname_prefix" {
  description = "GCP LPAD VM hostname prefix."
  value       = var.gcp_lpad_vm_hostname_prefix
}

output "gcp_ssh_username" {
  description = "GCP user name."
  value       = var.gcp_ssh_username
}

output "gcp_machine_type" {
  description = "GCE machine type to create."
  value       = var.gcp_machine_type
}

output "gcp_instance_template_name" {
  value       = module.instance_template.name
}

output "gcp_instance_template_tags" {
  value       = module.instance_template.tags
}

output "lpad_vm_private_ip" {
  description = "The private IP address assigned to the LPAD VM instance."
  value       = module.lpad_vm.network_ip
}

output "lpad_vm_public_ip" {
  description = "The external IP address assigned to the LPAD VM instance."
  value       = module.lpad_vm.nat_ip
}

output "lab_count" {
  description = "Number of Lab environments to launch."
  value       = var.lab_count
}

output "lab_start_number" {
  description = "Starting lab number for incrementally naming resources."
  value       = var.lab_start_number
}

output "lab_use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1"
  value       = var.lab_use_num_suffix
}

output "resource_labels" {
  description = "List of GCP resource labels."
  value       = var.resource_labels
}
