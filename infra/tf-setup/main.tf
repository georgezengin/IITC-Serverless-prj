# create s3 bucket to be used by terraform for arch deployment
# replace the bucket name in the target project with the name of the s3 bucket created by this script

resource "aws_s3_bucket" "remote_state" {
  bucket        = local.bucket_name
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = merge({ Name = local.bucket_name }, local.common_tags)
}

resource "aws_s3_bucket_acl" "remote_state_acl" {
  bucket = aws_s3_bucket.remote_state.id
  acl = "private"
}

resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.remote_state.id

  versioning_configuration {
    status = "Enabled"
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = local.bucket_name
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "s3Public_remote_state" {
  depends_on              = [aws_s3_bucket_policy.remote_state]
  bucket                  = aws_s3_bucket.remote_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id

  policy = <<POLICY
{
    "Version": "2008-10-17",
    "Statement": [
        {
          "Sid": "DenyInsecureAccess",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": [
            "${aws_s3_bucket.remote_state.arn}",
            "${aws_s3_bucket.remote_state.arn}/*"
          ],
          "Condition": {
            "Bool": {
              "aws:SecureTransport": "false"
            }
          }
        },
        {
          "Sid": "EnforceEncryption",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": [
            "${aws_s3_bucket.remote_state.arn}/*"
          ],
          "Condition": {
            "StringNotEquals": {
              "s3:x-amz-server-side-encryption": "AES256"
            }
          }
        },
        {
          "Sid": "DenyUnencryptedObjectUploads",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:PutObject",
          "Resource": [
            "${aws_s3_bucket.remote_state.arn}/*"
          ],
          "Condition": {
            "Null": {
              "s3:x-amz-server-side-encryption": "true"
            }
          }
        }
    ]
}
POLICY

}

resource "aws_dynamodb_table" "lock_table" {
  name           = local.tf_locks_table
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  tags           = local.common_tags

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_ssm_parameter" "remote_state_bucket" {
  name  = local.remote_state_name
  description = "Parameter for Terraform remote state bucket"
  type  = "String"
  value = aws_s3_bucket.remote_state.id
  tags  = merge({ Name = local.remote_state_name }, local.common_tags)
}
  
resource "aws_ssm_parameter" "locks_table_arn" {
  name  = local.tf_locks_tbl_arn
  type  = "String"
  value = aws_dynamodb_table.lock_table.arn
}
