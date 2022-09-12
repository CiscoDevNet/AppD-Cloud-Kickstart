# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.2.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.30"
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
