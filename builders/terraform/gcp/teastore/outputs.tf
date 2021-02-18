output "gcp_region" {
  description = "GCP region."
  value       = var.gcp_region
}

output "gcp_available_zones" {
  description = "List of zones available in the given GCP region."
  value       = data.google_compute_zones.available.names
}

output "gcp_teastore_vm_hostname_prefix" {
  description = "GCP TeaStore VM hostname prefix."
  value       = var.gcp_teastore_vm_hostname_prefix
}

output "gcp_ssh_username" {
  description = "GCP user name."
  value       = var.gcp_ssh_username
}

output "gcp_machine_type" {
  description = "GCE machine type to create."
  value       = var.gcp_machine_type
}

output "gcp_teastore_vm_instances_self_links" {
  description = "List of self-links for TeaStore VM compute instance"
  value       = module.teastore_vm.instances_self_links
}

output "gcp_instance_template_self_link" {
  value       = module.instance_template.self_link
}

output "gcp_instance_template_name" {
  value       = module.instance_template.name
}

output "gcp_instance_template_tags" {
  value       = module.instance_template.tags
}

output "gcp_teastore_vm_id" {
  description = "An identifier for the TeaStore VM resource."
  value       = module.teastore_vm.id
}

output "gcp_teastore_vm_instance_id" {
  description = "The server-assigned unique identifier of this TeaStore VM instance."
  value       = module.teastore_vm.instance_id
}

output "gcp_teastore_vm_network_ip" {
  description = "The private IP address assigned to the TeaStore VM instance."
  value       = module.teastore_vm.network_ip
}

output "gcp_teastore_vm_nat_ip" {
  description = "The external IP address assigned to the TeaStore VM instance."
  value       = module.teastore_vm.nat_ip
}

output "resource_labels" {
  description = "List of GCP resource labels."
  value       = var.resource_labels
}
