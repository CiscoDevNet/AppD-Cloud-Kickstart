variable "gcp_project_id" {
  description = "GCP Project ID."
  type        = string
  default     = "gcp-appdcloudplatfo-nprd-68190"
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone."
  type        = string
  default     = "us-central1-a"
}

variable "gcp_network" {
  description = "The network selflink to host the compute instances in"
  type        = string
  default     = "default"
}

variable "gcp_firewall_source_range" {
  description = "The source range for inbound ssh traffic"
  type        = list
  default     = ["0.0.0.0/0"]
}

#variable "gcp_subnetwork" {
#  description = "The subnetwork selflink to host the compute instances in"
#}

variable "gcp_teastore_vm_nat_ip" {
  description = "Public ip address for TeaStore VM instance."
  default     = null
}

variable "gcp_network_tier" {
  description = "Network network_tier"
  default     = "STANDARD"
}

variable "gcp_teastore_vm_hostname_prefix" {
  description = "GCP TeaStore VM hostname prefix."
  type        = string
  default     = "teastore-vm-node"
}

variable "gcp_ssh_username" {
  description = "GCP user name."
  type        = string
  default     = "centos"
}

variable "gcp_source_image_project" {
  description = "The source image project."
  type        = string
  default     = "gcp-appdcloudplatfo-nprd-68190"
# default     = "centos-cloud"
}

variable "gcp_source_image_family" {
  description = "The source image family."
  type        = string
  default     = "teastore-centos79-images"
# default     = "centos-7"
}

variable "gcp_source_image" {
  description = "The source disk image."
  type        = string
  default     = "teastore-centos79-2021-02-17"
# default     = "centos-7-v20200910"
}

variable "gcp_use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1"
  type        = bool
  default     = true
}

variable "gcp_machine_type" {
  description = "GCE machine type to create."
  type        = string
  default     = "e2-standard-2"
# default     = "e2-standard-4"
# default     = "n1-standard-1"
}

variable "gcp_resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "teastore"
}

variable "gcp_service_account" {
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
  type = object({
    email  = string,
    scopes = set(string)
  })
  default = {
    email = "devops@gcp-appdcloudplatfo-nprd-68190.iam.gserviceaccount.com",
    scopes = ["cloud-platform"]
  }
}

variable "gcp_ssh_pub_key_path" {
  default     = "../../../../shared/keys/AppD-Cloud-Kickstart-AWS.pub"
}

variable "resource_labels" {
  description = "Label names for GCP resources."
  type = map
  default = {
    "owner"   = "appdynamics-cloud-channel-sales-team"
    "project" = "appdynamics-cloud-kickstart"
    "event"   = "teastore-vm-deployment"
  }
}
