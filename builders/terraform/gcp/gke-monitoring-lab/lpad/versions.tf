# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.1.4"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.7, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
