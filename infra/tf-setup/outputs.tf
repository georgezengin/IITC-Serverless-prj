output "dynamodb-lock-table" {
  value       = aws_dynamodb_table.lock_table.name
  description = "DynamoDB table for Terraform execution locks"
}

output "dynamodb-lock-table-ssm-table" {
  value       = aws_ssm_parameter.locks_table_arn
  description = "SSM parameter containing DynamoDB table arn for Terraform execution locks"
  sensitive   = true
}

output "s3-state-bucket-id" {
  value       = aws_s3_bucket.remote_state.id
  description = "S3 bucket ID for storing Terraform state"
}

output "s3-state-bucket-name" {
  value       = aws_s3_bucket.remote_state.bucket
  description = "S3 bucket name for storing Terraform state"
}

output "s3-state-bucket-arn" {
  value       = aws_s3_bucket.remote_state.arn
  description = "S3 bucket ARN for storing Terraform state"
}

output "s3-remote-state-bucket-name-ssm-parameter" {
  value       = aws_ssm_parameter.remote_state_bucket.value
  description = "SSM parameter containing S3 bucket for storing Terraform state"
  sensitive   = true
}

output "aws_region" {
  value = var.aws_region
}

output "availability_zones" {
  value = data.aws_availability_zones.availability_zones.names
}