# Variables ----------------------------------------------------------------------------------------
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

output "apm_platform_vm_hostname_prefix" {
  description = "GCP APM Platform VM hostname prefix."
  value       = var.gcp_apm_platform_vm_hostname_prefix
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

output "apm_platform_vm_private_ip" {
  description = "The private IP address assigned to the APM Platform VM instance."
  value       = module.apm_platform_vm.network_ip
}

output "apm_platform_vm_public_ip" {
  description = "The external IP address assigned to the APM Platform VM instance."
  value       = module.apm_platform_vm.nat_ip
}

output "lab_count" {
  description = "Number of Lab environments to launch."
  value       = var.lab_count
}

output "lab_start_number" {
  description = "Starting lab number for incrementally naming resources."
  value       = var.lab_start_number
}

output "resource_labels" {
  description = "List of GCP resource labels."
  value       = var.resource_labels
}
