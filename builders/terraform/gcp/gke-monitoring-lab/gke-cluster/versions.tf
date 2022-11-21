# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.5"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.43, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
