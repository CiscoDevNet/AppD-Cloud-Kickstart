# Variables ----------------------------------------------------------------------------------------
variable "azurerm_workshop_resource_group_name" {
  description = "The Azure Resource Group Name for workshop resources."
  type        = string
  default     = "Cloud-Kickstart-Workshop"
}

variable "azurerm_ssh_username" {
  description = "Azure AKS node user name."
  type        = string
  default     = "ubuntu"
}

variable "azurerm_aks_kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster."
  type        = string
  default     = "1.18.17"
}

variable "azurerm_aks_node_count" {
  description = "Initial number of AKS nodes that should exist within the Node Pool."
  type        = number
  default     = 2
}

variable "azurerm_vm_size" {
  description = "Azure VM size."
  type        = string
# default     = "Standard_B1s"
  default     = "Standard_D2as_v4"
# default     = "Standard_B4ms"
}

variable "azurerm_resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "aks"
}

variable "lab_ssh_pub_key_path" {
  description = "Path to SSH public key for Lab VMs."
  type        = string
  default     = "../../../../../shared/keys/AppD-Cloud-Kickstart.pub"
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

variable "resource_tags" {
  description = "Tag names for Azure resources."
  type = map
  default = {
    "Owner"   = "AppDynamics Cloud Channel Sales Team"
    "Project" = "AppDynamics Cloud Kickstart"
    "Event"   = "Monitoring Azure AKS with AppDynamics Workshop"
  }
}
