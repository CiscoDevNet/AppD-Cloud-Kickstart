# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.7"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.39.1"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.3"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }

    random = {
      source = "hashicorp/random"
      version = ">= 3.4"
    }
  }
}
