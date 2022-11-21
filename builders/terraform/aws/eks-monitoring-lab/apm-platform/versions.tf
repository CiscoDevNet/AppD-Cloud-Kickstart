# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.2"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
