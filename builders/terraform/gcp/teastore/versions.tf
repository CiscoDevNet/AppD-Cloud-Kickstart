# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.7.3"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 5.16, < 6.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
