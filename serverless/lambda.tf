# Creating 3 Lambdas   

# (1)
resource "aws_lambda_function" "COMMIT-IITC-AWS-LAB-USER-LOG-IN" {
  filename         = var.user-log-lambda
  function_name    = var.function_name_user_login
  role             = aws_iam_role.COMMIT-pro-Lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256(var.user-log-lambda)

  environment {
    variables = {
      TABLE_NAME   = var.aws_dynamodb_table
      BUCKET       = var.aws_s3_bucket
      USER_MESSAGE = var.aws_user_message
      REGION       = var.aws_region
    }
  }
  depends_on = [
    aws_api_gateway_rest_api.rest_api_commit-proj,
  ]
}

# (2)
resource "aws_lambda_function" "COMMIT-IITC-AWS-LAB-DYNAMO-DB-GET-USERS" {
  filename         = var.users-lambda
  function_name    = var.function_name_get_users
  role             = aws_iam_role.COMMIT-pro-Lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256(var.users-lambda)

  environment {
    variables = {
      TABLE_NAME = var.aws_dynamodb_table
    }
  }

  depends_on = [
    aws_api_gateway_rest_api.rest_api_commit-proj,
  ]
}

# (3)
resource "aws_lambda_function" "COMMIT-IITC-AWS-LAB-COGNITO-TRIGGER-DYNAMO-DB" {
  filename         = var.cognito-dynamodb-lambda
  function_name    = var.function_name_cognito_dynamodb
  role             = aws_iam_role.COMMIT-pro-Lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256(var.cognito-dynamodb-lambda)

  environment {
    variables = {
      TABLE_NAME = var.aws_dynamodb_table
      REGION     = var.aws_region
    }
  }

  depends_on = [
    aws_api_gateway_rest_api.rest_api_commit-proj,
  ]
}

# There is another lambda for CloudWatch console log - to use it with API gateway End-Point   


# resource "aws_lambda_function" "cloudwatch_lambda" {
#   filename         = var.cloudwatch_lambda_file_name
#   function_name    = var.cloud_watch_function_name
#   role             = aws_iam_role.COMMIT-pro-Lambda_role.arn
#   handler          = "index.handler"
#   runtime          = "nodejs14.x"
#   source_code_hash = filebase64sha256(var.cloudwatch_lambda_file_path)
#   environment {
#     variables = {
#       AUTHENTICATED = "true"
#     }
#   }
# }

# data "aws_api_gateway_rest_api" "api_gateway" {
#   name = var.rest_api_name
# }