# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.8.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.48"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}
