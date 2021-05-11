# Outputs ------------------------------------------------------------------------------------------
output "resource_group" {
  description = "The name of the Azure Resource Group."
  value       = data.azurerm_resource_group.cloud_workshop.name
}

output "location" {
  description = "Azure Region where the Resource Group exists."
  value       = data.azurerm_resource_group.cloud_workshop.location
}

output "lab_ssh_username" {
  description = "Azure VM user name."
  value       = var.azurerm_ssh_username
}

output "aks_kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster."
  value       = var.azurerm_aks_kubernetes_version
}

output "aks_node_count" {
  description = "Initial number of AKS nodes that should exist within the Node Pool."
  value       = var.azurerm_aks_node_count
}

output "azurerm_vm_size" {
  description = "Azure VM size."
  value       = var.azurerm_vm_size
}

output "aks_cluster_host" {
  description = "The Kubernetes AKS Cluster server host."
  value       = flatten([toset(azurerm_kubernetes_cluster.k8s.*.kube_config.0.host)])
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
