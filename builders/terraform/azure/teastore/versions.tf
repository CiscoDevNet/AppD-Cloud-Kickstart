# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.4.5"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.52.0"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.4"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }

    random = {
      source = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}
