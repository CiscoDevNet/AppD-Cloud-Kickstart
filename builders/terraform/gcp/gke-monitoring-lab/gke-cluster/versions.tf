# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.2.0"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.21, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
