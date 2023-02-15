# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.9"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.53, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
