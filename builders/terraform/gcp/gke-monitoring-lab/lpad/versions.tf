# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.2.1"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.22, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
