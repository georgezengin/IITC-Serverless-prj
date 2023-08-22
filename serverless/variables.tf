# Main env name
variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  default     = "ohad"
}
variable "aws_config" {
  default = {}
}
variable "aws_access_key" {
  description = "AWS access key ID"
  default     = {}
}
variable "aws_secret_key" {
  description = "AWS secret access key"
  default     = {}
}

variable "aws_region" {
  description = "AWS region resources are deployed to"
  type        = string
  default     = "eu-central-1"
}

variable "rest_api_name" {
  type    = string
  default = "rest_api_commit-proj"
}
variable "function_name_get_users" {
  default = "COMMIT-IITC-AWS-LAB-DYNAMO-DB-GET-USERS"
}
variable "function_name_user_login" {
  default = "COMMIT-IITC-AWS-LAB-USER-LOG-IN"
}
variable "function_name_cognito_dynamodb" {
  default = "COMMIT-IITC-AWS-LAB-COGNITO-TRIGGER-DYNAMO-DB"
}
variable "users-lambda" {
  default = "../LAMBDAS/COMMIT-IITC-AWS-LAB-DYNAMO-DB-GET-USERS.zip"
}
variable "user-log-lambda" {
  default = "../LAMBDAS/COMMIT-IITC-AWS-LAB-USER-LOG-IN.zip"
}
variable "cognito-dynamodb-lambda" {
  default = "../LAMBDAS/COMMIT-IITC-AWS-LAB-COGNITO-TRIGGER-DYNAMO-DB.zip"
}
variable "aws_s3_bucket" {
  default = "upload-file-users"
}
variable "s3_function_name" {
  default = "user_file_web_app"
}
variable "parameter_store_name" {
  default = "ps-user-login-success"
}
variable "ssm_ps_parameter" {
  default = "/my-app/db-connection-string"
}
variable "value_messageToUser" {
  default = "successful-user-login"
}
variable "messageToUser_parameter" {
  default = "messageToUser-successToLogin"
}
variable "aws_cognito_user_pool" {
  default = "AUTH-USER-POOL-COMMIT-PROJ"
}
variable "aws_cognito_user_pool_client" {
  default = "commit-project-user-pool-client"
}
variable "api_authorizer" {
  default = "api_authorizer_web_application"
}
variable "aws_dynamodb_table" {
  default = "User_Authentication"
}
variable "aws_user_message" {
  default = "successful-user-login"
}
variable "aws_api_gateway_stage_name" {
  default = "dev"
}
variable "api_status_response" {
  default = ["200", "404", "500"]
}
variable "existing_user_pools" {
  default = "USER-LOGIN-AUTH"
}
variable "policies" {
  type = list(object({
    name     = string
    actions  = list(string)
    resource = string
  }))
  default = [
    {
      name     = "CloudWatchFullAccessPolicy"
      actions  = ["cloudwatch:*"]
      resource = "*"
    },
    {
      name     = "LambdaExecutePolicy"
      actions  = ["lambda:InvokeFunction"]
      resource = "*"
    },
    {
      name     = "AmazonDynamoDBFullAccess"
      actions  = ["dynamodb:*"]
      resource = "*"
    },
    {
      name     = "AWSLambdaInvocation-DynamoDB"
      actions  = ["lambda:InvokeFunction"]
      resource = "*"
    },
    {
      name     = "AWSLambdaRole"
      actions  = ["lambda:InvokeFunction"]
      resource = "*"
    },
    {
      name     = "AmazonCognitoPowerUser"
      actions  = [
        "cognito-idp:AdminCreateUser",
        "cognito-idp:AdminDeleteUser",
        "cognito-idp:AdminUpdateUserAttributes",
        "cognito-idp:ListUsers",
      ]
      resource = "*"
    },
    {
      name     = "AmazonCognitoDeveloperAuthenticatedIdentities"
      actions  = ["cognito-identity:*"]
      resource = "*"
    },
    {
      name     = "AWSLambdaBasicExecutionRole"
      actions  = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      resource = "*"
    },
    {
      name     = "AWSLambdaDynamoDBExecutionRole"
      actions  = [
        "dynamodb:Scan",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
      ]
      resource = "*"
    },
    {
      name     = "AmazonSSMFullAccess"
      actions  = ["ssm:*", "secretsmanager:GetSecretValue"]
      resource = "*"
    },
  ]
}

# variable "routes" {
#   type = map(object({
#     http_method   = string
#     authorization = string
#   }))
#   default = {
#     user = { http_method = "GET", authorization = "COGNITO_USER_POOLS" }
#     logs = { http_method = "GET", authorization = "COGNITO_USER_POOLS" }
#   }
# }

variable "api_authorizer_arn" {
  default = "arn:aws:cognito-idp:eu-central-1:882728657756:userpool/eu-central-1_vlNVFypvD"
}


