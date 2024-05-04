# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.8.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.48"
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
