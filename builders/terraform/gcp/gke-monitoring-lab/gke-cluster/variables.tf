# Variables ----------------------------------------------------------------------------------------
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

variable "gcp_firewall_source_range" {
  description = "The source range for inbound ssh traffic"
  type        = list
  default     = ["0.0.0.0/0"]
}

variable "gke_username" {
  description = "Username to use for HTTP basic authentication when accessing the Kubernetes master endpoint."
  default     = ""
}

variable "gke_password" {
  description = "Password to use for HTTP basic authentication when accessing the Kubernetes master endpoint."
  default     = ""
}

variable "gke_node_count" {
  description = "Number of GKE nodes per instance group."
  default     = 2
}

variable "gcp_machine_type" {
  description = "GCE machine type to create for GKE cluster Node Pool."
  type        = string
  default     = "e2-standard-2"
# default     = "n1-standard-1"
# default     = "n2-standard-2"
}

variable "gcp_resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "gke"
}

variable "gcp_service_account_key_path" {
  description = "Service account key path to credentials in JSON format."
  type        = string
  default     = "../../../../../shared/keys/gcp-devops.json"
}

variable "gke_kubernetes_version" {
  description = "The Kubernetes version. If set to 'latest' it will pull latest available version in the selected region."
  type        = string
  default     = "latest"
# default     = "1.20.10-gke.301"
# default     = "1.20.9-gke.1001"
}

variable "gke_release_channel" {
  description = "The release channel of this cluster. Accepted values are UNSPECIFIED, RAPID, REGULAR and STABLE. Defaults to UNSPECIFIED."
  type        = string
  default     = "RAPID"
# default     = "REGULAR"
# default     = "STABLE"
# default     = "UNSPECIFIED"
}

variable "lab_count" {
  description = "Number of Lab environments to launch."
  type        = number
  default     = 2
}

variable "lab_start_number" {
  description = "Starting lab number for incrementally naming resources."
  type        = number
  default     = 1
}

variable "lab_use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1."
  type        = bool
  default     = true
}

variable "resource_labels" {
  description = "Label names for GCP resources."
  type = map
  default = {
    "owner"   = "appdynamics-cloud-channel-sales-team"
    "project" = "appdynamics-cloud-kickstart"
    "event"   = "gke-monitoring-workshop"
  }
}
