# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.6.6"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.31"
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
