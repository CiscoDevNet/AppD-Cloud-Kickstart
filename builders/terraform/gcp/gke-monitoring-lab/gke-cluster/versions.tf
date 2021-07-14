# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.2"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "= 3.75"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
