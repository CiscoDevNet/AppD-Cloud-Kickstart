# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.49"
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
