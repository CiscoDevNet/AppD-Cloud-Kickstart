# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.4"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.75, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
