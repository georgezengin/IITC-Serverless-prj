# uncomment next lines to set backend to local, then run 'terraform init -migrate-state' on your CLI
/* terraform {
  backend "local" {
    path = "terraform.tfstate" 
  } 
} */

# to enable s3 bucket, uncomment next blocks and replace name of bucket to your own created bucket
# also set name of bucket in variables.tf file
terraform {
  backend "s3" {
    bucket         = "commit-proj-dev-1.0-s3"
    key            = "commit-proj-dev-1.0.terraform.tfstate" #local.state_file_name
    region         = "eu-central-1"
    dynamodb_table = "commit-proj-dev-1.0-tf-locks-table"

    encrypt        = true
  }
}

# just define some variables to have the backend details for further reuse
# terraform does not allow to use variables in backend block -> redundant definition
#
variable "s3_tfstate_bucket" {
  default = "commit-proj-dev-1.0-s3"
}

variable "s3_tfstate_key" {
  default = "commit-proj-dev-1.0.terraform.tfstate"
}

variable "dynamo_tflock_table" {
  default = "commit-proj-dev-1.0-tf-locks-table"
}

# resource "aws_s3_bucket_versioning" "enabled" {
#   bucket = var.s3_tfstate_bucket
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
#   bucket = var.s3_tfstate_bucket
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
# resource "aws_s3_bucket_public_access_block" "public_access" {
#   bucket                  = var.s3_tfstate_bucket
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
# resource "aws_dynamodb_table" "terraform_states_locks" {
#  name         = "commit-proj-dev-1.0-tf-locks-table"
#  billing_mode = "PAY_PER_REQUEST"
#  hash_key     = "LockID"
#  attribute {
#    name = "LockID"
#    type = "S"
#  }
# }