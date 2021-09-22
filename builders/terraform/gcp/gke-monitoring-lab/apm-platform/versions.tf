# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.7"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.84"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
