# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.7.4"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.95.0"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.5"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }

    random = {
      source = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}
