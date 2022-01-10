# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.71"
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
