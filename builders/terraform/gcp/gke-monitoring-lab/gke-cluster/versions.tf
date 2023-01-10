# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.7"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.48, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
