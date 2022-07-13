# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.2.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.13.0"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.2"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }

    random = {
      source = "hashicorp/random"
      version = ">= 3.3"
    }
  }
}
