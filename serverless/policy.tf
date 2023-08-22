resource "aws_iam_role" "COMMIT-pro-Lambda_role" {
  name = "lambda-role-Commit-Pro"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "apigateway.amazonaws.com",
            "cognito-idp.amazonaws.com",
          ]
        }
      }
    ]
  })
  tags = {
    Name = "Lambda Execution Role"
  }
}
resource "aws_iam_policy" "lambda_policies" {
  count       = length(var.policies)
  name_prefix = var.policies[count.index].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = var.policies[count.index].actions
        Resource = var.policies[count.index].resource
      }
    ]
  })
}
# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_role_attachments" {
  for_each = { for idx, policy in var.policies : idx => policy }

  policy_arn = aws_iam_policy.lambda_policies[each.key].arn
  role       = aws_iam_role.COMMIT-pro-Lambda_role.name
}

# resource "aws_iam_policy" "lambda_policy" {
#   name        = "Commit-Project-lambda-policy"
#   description = "IAM policy for Lambda function"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:CreateLogStream",
#           "dynamodb:GetItem",
#           "dynamodb:PutItem",
#           "s3:PutObject",
#           "s3:PutObjectAcl",
#           "ssm:GetParameter",
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   policy_arn = aws_iam_policy.lambda_policy.arn
#   role       = aws_iam_role.COMMIT-pro-Lambda_role.name
# }

# Associate the Lambda function permission with the API Gateway
resource "aws_lambda_permission" "lambda_trigger_users_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name_log_in_user
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_deployment.api_gateway_deployment.execution_arn
}

resource "aws_lambda_permission" "lambda_trigger_log_in_user_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name_log_in_user
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_deployment.api_gateway_deployment.execution_arn
}
# resource "aws_iam_role_policy" "invocation_policy" {
#   name   = "default"
#   role   = aws_iam_role.invocation_role.id
#   policy = data.aws_iam_policy_document.invocation_policy.json
# }


