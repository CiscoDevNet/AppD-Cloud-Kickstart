# Variables ----------------------------------------------------------------------------------------
output "location" {
  description = "Azure region."
  value       = var.azurerm_location
}

output "lpad_vm_hostname_prefix" {
  description = "Azure LPAD VM hostname prefix."
  value       = var.azurerm_lpad_vm_hostname_prefix
}

output "lab_ssh_username" {
  description = "Azure VM user name."
  value       = var.azurerm_ssh_username
}

output "azurerm_vm_size" {
  description = "Azure VM size."
  value       = var.azurerm_vm_size
}

output "lpad_private_ips" {
  description = "The private IP addresses assigned to the LPAD VM instances."
  value       = flatten([toset(azurerm_linux_virtual_machine.lpad.*.private_ip_address)])
}

output "lpad_public_ips" {
  description = "The public IP addresses assigned to the LPAD VM instances."
  value       = flatten([toset(azurerm_linux_virtual_machine.lpad.*.public_ip_address)])
}

output "lab_count" {
  description = "Number of Lab environments to launch."
  value       = var.lab_count
}

output "lab_start_number" {
  description = "Starting lab number for incrementally naming resources."
  value       = var.lab_start_number
}

output "resource_tags" {
  description = "Tag names for Azure resources."
  value       = var.resource_tags
}
