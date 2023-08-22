resource "aws_s3_bucket" "user_file_backend" {
  bucket = var.aws_s3_bucket
  acl    = "private"
  versioning {
    enabled = true
  }
}
# lifecycle {
#   prevent_destroy = false
# }


