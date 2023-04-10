# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.4.4"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.60, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
