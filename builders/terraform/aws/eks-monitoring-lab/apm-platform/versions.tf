# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.52"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.3"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }
  }
}
