
# Creating DynamoDB Table  
resource "aws_dynamodb_table" "dynamodb_table" {
  name         = var.aws_dynamodb_table
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "email"
  attribute {
    name = "email"
    type = "S"
  }
}
resource "aws_lambda_permission" "dynamodb_permission" {
  statement_id  = "AllowDynamoDBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.dynamodb_function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = aws_dynamodb_table.dynamodb_table.arn
}
