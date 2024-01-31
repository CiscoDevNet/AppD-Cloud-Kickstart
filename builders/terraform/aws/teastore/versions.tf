# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.7.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.34"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.4"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
