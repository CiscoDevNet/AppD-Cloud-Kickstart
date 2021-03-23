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
data "google_compute_zones" "available" {
}

# Modules ------------------------------------------------------------------------------------------
module "instance_template" {
  source  = "./modules/instance_template"

  region               = var.gcp_region
  project_id           = var.gcp_project_id
  service_account      = var.gcp_service_account
  network              = google_compute_network.vpc.name
  subnetwork           = google_compute_subnetwork.vpc-public-subnet-01.name
  source_image_project = var.gcp_source_image_project
  source_image_family  = var.gcp_source_image_family
# source_image         = var.gcp_source_image
  machine_type         = var.gcp_machine_type
  disk_size_gb         = 128

  metadata = {
    ssh-keys = "${var.gcp_ssh_username}:${file(var.gcp_ssh_pub_key_path)}"
    startup-script = templatefile("${path.module}/templates/user-data-sh.tmpl", {
      gcp_ssh_username                    = var.gcp_ssh_username,
      gcp_apm_platform_vm_hostname_prefix = var.gcp_apm_platform_vm_hostname_prefix,
      gcp_apm_platform_vm_domain          = "",
      gcp_use_num_suffix                  = "true"
    })
  }

  labels = var.resource_labels
}

module "apm_platform_vm" {
  source  = "./modules/compute_instance"

  num_instances  = var.lab_count
  use_num_suffix = true

  region            = var.gcp_region
  zone              = var.gcp_zone
  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.vpc-public-subnet-01.name
  hostname          = var.gcp_apm_platform_vm_hostname_prefix
  instance_template = module.instance_template.self_link
  labels            = var.resource_labels

  access_config = [
    {
      nat_ip       = null
      network_tier = var.gcp_network_tier
    },
  ]
}

# Resources ----------------------------------------------------------------------------------------
resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.gcp_resource_name_prefix}-${local.current_date}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "vpc-public-subnet-01" {
  name          = "subnet-${var.gcp_resource_name_prefix}-${local.current_date}-01"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "vpc-public-subnet-02" {
  name          = "subnet-${var.gcp_resource_name_prefix}-${local.current_date}-02"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "allow-icmp" {
  name    = "firewall-rule-allow-icmp-${var.gcp_resource_name_prefix}-${local.current_date}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  source_ranges = var.gcp_firewall_source_range
# target_tags   = ["allow-icmp"]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "firewall-rule-allow-internal-${var.gcp_resource_name_prefix}-${local.current_date}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
# target_tags   = ["allow-internal"]
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "firewall-rule-allow-ssh-${var.gcp_resource_name_prefix}-${local.current_date}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = var.gcp_firewall_source_range
# target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow-apm-platform" {
  name    = "firewall-rule-allow-apm-platform-${var.gcp_resource_name_prefix}-${local.current_date}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["80", "443", "3306", "8080", "8090", "9080", "9191"]
  }

  source_ranges = ["0.0.0.0/0"]
# target_tags   = ["allow-apm-platform"]
}

# create ansible trigger to generate inventory and helper files. -----------------------------------
resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when any vm instance requires re-provisioning.
  triggers = {
    gcp_instance_ids = join(",", concat(module.apm_platform_vm.instance_id))
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible gcp hosts inventory.
  provisioner "local-exec" {
    working_dir = "."
    command = <<EOD
cat <<EOF > gcp_hosts.inventory
[apm_platform_vm]
${join("\n", toset(module.apm_platform_vm.nat_ip))}
EOF
EOD
  }
}
