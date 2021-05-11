# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.15.3"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.39"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.1"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
