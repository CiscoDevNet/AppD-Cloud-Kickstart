# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.5"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.81"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
