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

output "gke_node_count" {
  description = "Number of GKE nodes per instance group."
  value       = var.gke_node_count
}

output "gcp_machine_type" {
  description = "GCP machine type to create."
  value       = var.gcp_machine_type
}

output "kubernetes_cluster_name" {
  description = "GKE cluster name."
  value       = google_container_cluster.gke_cluster[*].name
}

output "kubernetes_cluster_host" {
  description = "GKE cluster host."
  value       = google_container_cluster.gke_cluster[*].endpoint
}

output "kubernetes_release_channel_version" {
  description = "GKE release channel version."
  value       = data.google_container_engine_versions.zone.release_channel_default_version[var.gke_release_channel]
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
