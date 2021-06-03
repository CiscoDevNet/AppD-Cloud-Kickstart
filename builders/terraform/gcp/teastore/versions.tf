# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.15.5"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.70"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
