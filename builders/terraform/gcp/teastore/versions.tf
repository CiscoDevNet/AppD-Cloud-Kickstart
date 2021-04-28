# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.15.1"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.65"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
