# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.1"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.39, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
