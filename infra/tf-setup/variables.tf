variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  default     = "default"
}

variable "aws_config" {
  default = {}
}

variable "env" {
  default = {}
}

variable "company" {
  description = "Name of the customer or project"
  type        = string
  default     = "iitc"
}

variable "project" {
  description = "Name of the project"
  type        = string
  default     = "commit-proj"
}

variable "environment" {
  description = "Environment description (i.e dev/prod/test)"
  default = "dev"
}

variable "release_version" {
    description = "Release/Iteration/Sprint/Build number or name"
    default = "1.0"
}

variable "aws_region" {
  description = "AWS region resources are deployed to"
  type        = string
  default     = "eu-central-1"
}

data "aws_availability_zones" "availability_zones" {
    state = "available"
}

# variable "availability_zones" {
#   description = "List of availability zones"
#   type        = list(string)
#   default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
# }

#export AWS_ACCESS_KEY_ID=
#export AWS_SECRET_ACCESS_KEY=
variable "aws_access_key" {
  description = "AWS access key ID"
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  default     = ""
}
