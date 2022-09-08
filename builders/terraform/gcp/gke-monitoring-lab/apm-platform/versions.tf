# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.2.9"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.35, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
