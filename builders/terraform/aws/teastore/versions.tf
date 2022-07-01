# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.2.4"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.21"
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
