# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.3"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.35"
    }

    local = {
      source = "hashicorp/local"
      version = ">= 2.2"
    }

    null = {
      source = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
