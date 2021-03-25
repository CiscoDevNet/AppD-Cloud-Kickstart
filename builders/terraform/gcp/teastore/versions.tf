# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.9"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.61"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
