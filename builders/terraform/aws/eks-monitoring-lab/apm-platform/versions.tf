# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.4.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.63"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.4"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
