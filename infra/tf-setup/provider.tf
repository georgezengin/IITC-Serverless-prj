# Terraform Providers

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      source = "hashicorp/local"
    }
  }

}

provider "aws" {
  access_key = local.l_aws_access_key
  secret_key = local.l_aws_secret_key
  region     = local.l_aws_region
  profile    = local.l_aws_profile
}
