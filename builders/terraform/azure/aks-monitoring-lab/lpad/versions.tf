# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.74.0"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.1"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }

    random = {
      source = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}
