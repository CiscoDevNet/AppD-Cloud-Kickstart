# Providers ----------------------------------------------------------------------------------------
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
  credentials = var.gcp_service_account_key_path
}

# Locals -------------------------------------------------------------------------------------------
locals {
  current_date = formatdate("YYYY-MM-DD", timestamp())
  start_number = var.lab_start_number
}

# Data Sources -------------------------------------------------------------------------------------
data "google_client_config" "default" {
}

data "google_compute_zones" "available" {
}

data "google_container_engine_versions" "zone" {
  location = var.gcp_zone
}

# Resources ----------------------------------------------------------------------------------------
resource "google_compute_network" "vpc" {
  name   = "${var.gcp_resource_name_prefix}${format("%02d", count.index + local.start_number)}-vpc-${local.current_date}"
  count  = var.lab_count

  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name   = "${var.gcp_resource_name_prefix}${format("%02d", count.index + local.start_number)}-subnet-${local.current_date}"
  region = var.gcp_region
  count  = var.lab_count

  network       = google_compute_network.vpc[count.index].name
  ip_cidr_range = "10.10.0.0/24"
}

resource "google_container_cluster" "gke_cluster" {
  name     = "${var.gcp_resource_name_prefix}${format("%02d", count.index + local.start_number)}-gke-${local.current_date}"
  location = var.gcp_zone
  count    = var.lab_count

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc[count.index].name
  subnetwork = google_compute_subnetwork.subnet[count.index].name

  release_channel {
    channel = var.gke_release_channel
  }

  resource_labels = var.resource_labels

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "gke_cluster_nodes" {
  name     = "${var.gcp_resource_name_prefix}${format("%02d", count.index + local.start_number)}-gke-node-pool-${local.current_date}"
  location = var.gcp_zone
  count    = var.lab_count

  cluster    = google_container_cluster.gke_cluster[count.index].name
  node_count = var.gke_node_count

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.gcp_resource_name_prefix
    }

    machine_type = var.gcp_machine_type
    tags         = ["gke-node", "${var.gcp_resource_name_prefix}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
