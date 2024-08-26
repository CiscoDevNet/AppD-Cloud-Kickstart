# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.9.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 4.0.1"
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
