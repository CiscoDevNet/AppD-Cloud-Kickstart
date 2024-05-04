# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.8.2"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.27, < 6.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
