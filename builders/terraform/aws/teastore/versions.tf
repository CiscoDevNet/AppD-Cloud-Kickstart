# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.4.1"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.58"
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
