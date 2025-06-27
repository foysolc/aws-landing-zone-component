terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0" # This means specific version 5.40.0
    }
  }
  required_version = ">= 1.0.0" # Ensures you're using a compatible Terraform CLI version
}