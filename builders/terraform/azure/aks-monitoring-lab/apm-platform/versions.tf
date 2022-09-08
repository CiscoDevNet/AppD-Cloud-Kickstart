# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.2.9"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.21.1"
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
      version = ">= 3.4"
    }
  }
}
