# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.15.3"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "= 3.68"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
