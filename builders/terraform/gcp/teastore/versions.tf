# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.8"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.87"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
