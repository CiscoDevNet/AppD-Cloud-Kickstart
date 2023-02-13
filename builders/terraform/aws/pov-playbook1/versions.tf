# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.3.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.54"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.3"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.4"
    }
  }
}
