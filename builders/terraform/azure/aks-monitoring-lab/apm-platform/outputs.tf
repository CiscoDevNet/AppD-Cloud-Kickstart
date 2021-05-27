# Outputs ------------------------------------------------------------------------------------------
output "resource_group" {
  description = "The name of the Azure Resource Group for workshop resources."
  value       = data.azurerm_resource_group.cloud_workshop.name
}

output "location" {
  description = "Azure Region where the Resource Group exists."
  value       = data.azurerm_resource_group.cloud_workshop.location
}

output "apm_platform_vm_hostname_prefix" {
  description = "Azure APM Platform VM hostname prefix."
  value       = var.azurerm_apm_platform_vm_hostname_prefix
}

output "lab_ssh_username" {
  description = "Azure VM user name."
  value       = var.azurerm_ssh_username
}

output "azurerm_vm_size" {
  description = "Azure VM size."
  value       = var.azurerm_vm_size
}

output "apm_platform_private_ips" {
  description = "The private IP addresses assigned to the APM Platform VM instances."
  value       = flatten([toset(azurerm_linux_virtual_machine.apm_platform.*.private_ip_address)])
}

output "apm_platform_public_ips" {
  description = "The public IP addresses assigned to the APM Platform VM instances."
  value       = flatten([toset(azurerm_linux_virtual_machine.apm_platform.*.public_ip_address)])
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

output "resource_tags" {
  description = "Tag names for Azure resources."
  value       = var.resource_tags
}
