# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.4.6"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.64, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
