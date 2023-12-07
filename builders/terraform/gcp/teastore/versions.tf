# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.6.5"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.8, < 6.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
