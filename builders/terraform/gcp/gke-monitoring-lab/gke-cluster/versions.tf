# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.10"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "= 3.63"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
