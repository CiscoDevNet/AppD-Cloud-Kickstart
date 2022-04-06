# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.1.7"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.16, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
