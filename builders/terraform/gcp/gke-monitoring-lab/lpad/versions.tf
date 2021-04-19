# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.15.0"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.64"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
