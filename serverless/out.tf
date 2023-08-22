output "dynamodb-lock-table" {
  value       = var.aws_dynamodb_table
  description = "DynamoDB table name using Terraform"
}
output "s3-state-bucket-id" {
  value       = aws_s3_bucket.user_file_backend.id
  description = "S3 bucket ID for storing Terraform state"
}
output "aws_ssm_parameter" {
  value       = var.value_messageToUser
  description = "Parameter_Store_parameter containing S3 bucket for storing Terraform state"
  sensitive   = true
}
output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.auth-user-pool-commitPro.arn
}
output "aws_s3_bucket_object" {
  value = aws_s3_bucket.user_file_backend.id
}
# data "aws_caller_identity" "current" {}
# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }