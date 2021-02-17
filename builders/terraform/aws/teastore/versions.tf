# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.14.7"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.28"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.0"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
