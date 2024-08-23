# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.9.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.64"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.5"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
