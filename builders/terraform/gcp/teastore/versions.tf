# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.7"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 3.57"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
