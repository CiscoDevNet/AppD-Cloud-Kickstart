# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.2.4"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 4.27, < 5.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
