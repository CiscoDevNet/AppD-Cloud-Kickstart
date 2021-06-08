# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "= 3.71"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
