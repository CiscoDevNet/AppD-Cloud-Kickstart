# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.34"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.2"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.1"
    }
  }
}
