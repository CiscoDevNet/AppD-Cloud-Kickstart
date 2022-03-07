# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.4"
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
