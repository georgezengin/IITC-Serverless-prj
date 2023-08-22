
# API Gateway
resource "aws_api_gateway_rest_api" "rest_api_commit-proj" {
  name        = var.rest_api_name
  description = "API Gateway for frontend application"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource - User - Route
resource "aws_api_gateway_resource" "user_route" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_commit-proj.id
  parent_id   = aws_api_gateway_rest_api.rest_api_commit-proj.root_resource_id
  path_part   = "users"
}

# API Gateway Method - GET User Route
resource "aws_api_gateway_method" "get_user_route" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_commit-proj.id
  resource_id   = aws_api_gateway_resource.user_route.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true,
  }

  depends_on = [
    aws_api_gateway_rest_api.rest_api_commit-proj,
  ]
}

# API Gateway Resource - Log - Route
resource "aws_api_gateway_resource" "log_route" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_commit-proj.id
  parent_id   = aws_api_gateway_rest_api.rest_api_commit-proj.root_resource_id
  path_part   = "user-log"
}

# API Gateway Method - GET Log Route
resource "aws_api_gateway_method" "get_log_route" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_commit-proj.id
  resource_id   = aws_api_gateway_resource.log_route.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true,
  }

  depends_on = [
    aws_api_gateway_rest_api.rest_api_commit-proj,
  ]
}

# API Gateway Integration - POST Log Route
resource "aws_api_gateway_integration" "lambda_integration_log_routh" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_commit-proj.id
  resource_id             = aws_api_gateway_resource.log_route.id
  http_method             = aws_api_gateway_method.get_log_route.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.COMMIT-IITC-AWS-LAB-USER-LOG-IN.invoke_arn
}

# API Gateway Integration Response - Log Route
resource "aws_api_gateway_method_response" "get_log_route_response" {
  for_each    = toset(var.api_status_response)
  rest_api_id = aws_api_gateway_rest_api.rest_api_commit-proj.id
  resource_id = aws_api_gateway_resource.log_route.id
  http_method = aws_api_gateway_method.get_log_route.http_method
  status_code = each.value
}

# API Gateway Integration - POST User Route
resource "aws_api_gateway_integration" "lambda_integration_user_routh" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api_commit-proj.id
  resource_id             = aws_api_gateway_resource.user_route.id
  http_method             = aws_api_gateway_method.get_user_route.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.COMMIT-IITC-AWS-LAB-DYNAMO-DB-GET-USERS.invoke_arn
}

# API Gateway Integration Response - User Route
resource "aws_api_gateway_method_response" "get_user_route_response" {
  for_each    = toset(var.api_status_response)
  rest_api_id = aws_api_gateway_rest_api.rest_api_commit-proj.id
  resource_id = aws_api_gateway_resource.user_route.id
  http_method = aws_api_gateway_method.get_user_route.http_method
  status_code = each.value
}

# API Gateway Authorizer 
resource "aws_api_gateway_authorizer" "api_authorizer" {
  name                             = var.api_authorizer
  rest_api_id                      = aws_api_gateway_rest_api.rest_api_commit-proj.id
  authorizer_uri                   = aws_lambda_function.COMMIT-IITC-AWS-LAB-COGNITO-TRIGGER-DYNAMO-DB.invoke_arn
  authorizer_result_ttl_in_seconds = 300
  identity_source                  = "method.request.header.Authorization"
  type                             = "COGNITO_USER_POOLS"
  provider_arns                    = [aws_cognito_user_pool.auth-user-pool-commitPro.arn]
}

# API Gateway Deployment 
resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_commit-proj.id

  depends_on = [
    aws_api_gateway_method.get_user_route,
    aws_api_gateway_integration.lambda_integration_user_routh
  ]
}
# API Gateway Deployment Stage
resource "aws_api_gateway_stage" "api_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api_commit-proj.id
  stage_name    = var.aws_api_gateway_stage_name
}

