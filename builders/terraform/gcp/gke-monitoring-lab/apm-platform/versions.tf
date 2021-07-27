# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.3"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.76"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
