# Providers ----------------------------------------------------------------------------------------
provider "azurerm" {
  features {}
}

# Locals -------------------------------------------------------------------------------------------
locals {
  current_date = formatdate("YYYY-MM-DD", timestamp())
  start_number = var.lab_start_number
}

# Data Sources -------------------------------------------------------------------------------------
data "azurerm_resource_group" "cloud_workshop" {
  name     = var.azurerm_workshop_resource_group_name
}

# Modules ------------------------------------------------------------------------------------------

# Resources ----------------------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "k8s" {
  name  = var.lab_count > 1 || var.lab_use_num_suffix ? format("%s-%02d-cluster-%s", var.azurerm_resource_name_prefix, count.index + local.start_number, local.current_date) : "${var.azurerm_resource_name_prefix}-cluster-${local.current_date}"
  count = var.lab_count

  resource_group_name = data.azurerm_resource_group.cloud_workshop.name
  location            = data.azurerm_resource_group.cloud_workshop.location
  kubernetes_version  = var.azurerm_aks_kubernetes_version
  dns_prefix          = var.lab_count > 1 || var.lab_use_num_suffix ? format("%s-%02d-cluster-%s", var.azurerm_resource_name_prefix, count.index + local.start_number, local.current_date) : "${var.azurerm_resource_name_prefix}-cluster-${local.current_date}"

  linux_profile {
    admin_username = var.azurerm_ssh_username

    ssh_key {
      key_data = file(var.lab_ssh_pub_key_path)
    }
  }

  default_node_pool {
    name       = var.lab_count > 1 || var.lab_use_num_suffix ? format("%s%02dnp", var.azurerm_resource_name_prefix, count.index + local.start_number) : "${var.azurerm_resource_name_prefix}np"
    node_count = var.azurerm_aks_node_count
    vm_size    = var.azurerm_vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin = "kubenet"
  }

  tags = var.resource_tags
}
