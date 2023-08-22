terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9.0"
    }
  }
}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  # Make it faster by skipping validation
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}