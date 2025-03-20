# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.11.2"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.44, < 6.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
