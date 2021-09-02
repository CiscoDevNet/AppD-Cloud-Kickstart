# Variables ----------------------------------------------------------------------------------------
variable "azurerm_images_resource_group_name" {
  description = "The Azure Resource Group Name for VM images."
  type        = string
  default     = "Cloud-Kickstart-Workshop-Images"
}

variable "azurerm_workshop_resource_group_name" {
  description = "The Azure Resource Group Name for workshop resources."
  type        = string
  default     = "Cloud-Kickstart-Workshop"
}

variable "azurerm_source_address_prefixes" {
  description = "The source range for inbound ssh traffic"
  type        = list
  default     = ["0.0.0.0/0"]
}

variable "azurerm_ssh_username" {
  description = "Azure VM user name."
  type        = string
  default     = "centos"
}

variable "azurerm_lab_tcp_idle_timeout" {
  description = "Azure VM public IP idle timeout in minutes."
  type        = number
  default     = 30
}

variable "azurerm_shared_image_gallery" {
  description = "The name of the shared image gallery."
  type        = string
  default     = "CloudKickstartWorkshopGallery"
}

variable "azurerm_shared_image_definition" {
  description = "The shared image gallery image definition."
  type        = string
  default     = "TeaStore-CentOS79"
}

variable "azurerm_shared_image_version" {
  description = "The shared image gallery image version."
  type        = string
  default     = "latest"
# default     = "1.0.0"
}

variable "azurerm_vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_D2as_v4"
}

variable "azurerm_teastore_vm_hostname_prefix" {
  description = "Azure TeaStore VM hostname prefix."
  type        = string
  default     = "teastore"
}

variable "azurerm_resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "teastore"
}

variable "azurerm_storage_account_type" {
  description = "Azure storage account type."
  type        = string
  default     = "Standard_LRS"
# default     = "StandardSSD_LRS"
# default     = "Premium_LRS"
}

variable "lab_ssh_pub_key_path" {
  description = "Path to SSH public key for Lab VMs."
  type        = string
  default     = "~/.ssh/AppD-Cloud-Kickstart.pub"
# default     = "../../../../../shared/keys/AppD-Cloud-Kickstart.pub"
}

variable "lab_count" {
  description = "Number of Lab environments to launch."
  type        = number
  default     = 1
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
    "Event"   = "AppD TeaStore VM Deployment"
  }
}
