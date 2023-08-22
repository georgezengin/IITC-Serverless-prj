
resource "aws_ssm_parameter" "messageToUser_parameter" {
  name  = var.aws_user_message
  type  = "String"
  value = "hello"
  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_ssm_parameter" "ssm_ps_parameter" {
#   name        = var.ssm_ps_parameter
#   description = "This is the parameter for our app"
#   type        = "String"

#   value = "key.parameter.db"
# }