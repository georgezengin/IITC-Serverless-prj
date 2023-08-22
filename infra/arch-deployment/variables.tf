# Terraform Variables
# main env name
variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  default     = "default"
}

variable "aws_config" {
  default = {}
}

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

variable "env" {
  default = {}
}

variable "company" {
  description = "Name of the customer or project"
  type        = string
  default     = "company"
}

variable "project" {
  description = "Name of the project"
  type        = string
  default     = "proj-name"
}

variable "environment" {
  description = "Environment description (i.e dev/prod/test)"
  default = "alpha" # prod, uat, systest, poc, any value that identifies the environment usage
}

variable "release_version" {
    description = "Release/Iteration/Sprint/Build number or name"
    default = "v0-1"
}

variable "aws_region" {
  description = "AWS region resources are deployed to"
  type        = string
  default     = "eu-central-1"
}

data "aws_availability_zones" "availability_zones" {
    state = "available"
}

#variable "availability_zones" {
#  description = "Availability zones to be used"
#  type = list(string)
#  default = local.default_availability_zones # data.aws_availability_zones.available_zones.names
#}

# VPC Variables
variable "vpc_id" { default = "" }
variable "public_subnet_id" { default = "" }

variable "vpc_cidr" {
  description = "VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_tenancy" {
  type    = string
  default = "default"
}

variable "public_subnets_quantity" {
  description = "Total public subnets to generate"
  type        = number
  default     = 1
}

variable "public_subnets_cidr" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = [] #["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_quantity" {
  description = "Total public subnets to generate"
  type        = number
  default     = 1
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = [] #["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_subnets_quantity" {
  description = "Total database subnets to generate"
  type        = number
  default     = 0
}

variable "db_subnets_cidr" {
  description = "CIDR blocks for db subnets"
  type        = list(string)
  default     = [] #["10.11.21.0/24", "10.11.22.0/24"]
}

variable "alltraffic_cidr" {
  description = "All traffic CIDR - for sec group"
  type        = string
  default     = "0.0.0.0/0"
}

variable "s3_app_bucket_name" {
  type        = string
  description = "Name of S3 bucket for VPC endpoint of private subnets"
  default     = "s3-endpoint"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of DynamoDB table name for VPC endpoint of db subnets"
  default     = "db-login-log"
}

variable "public_access_ssh"{
  description = "Flag to allow public access to EC2s using SSH as opposed to private (from author's public IP)"
  type        = string
  default     = "yes"
}

# EC2 Variables

variable "create_public_ec2s" {
  description = "flag for creation of EC2s in public subnets"
  type        = bool
  default     = false
} 

variable "create_private_ec2s" {
  description = "flag for creation of EC2s in private subnets"
  type        = bool
  default     = false
} 

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_ami_web" {
  description = "AMI-Id to use to build EC2 instance in web layer"
  type        = string
  default     = ""
}

variable "instance_ami_app" {
  description = "AMI-Id to use to build EC2 instance in app layer"
  type        = string
  default     = ""
}

variable "ssh_key" {
  description = "ssh key name"
  type        = string
  default     = "my-ssh-key"
}

variable "ssh_path" {
  description = "ssh key path"
  type        = string
  default     = "./" # ~/.ssh
}

variable "email_addr_sns" {
  default = "a@b.com"
}

variable "ec2_private_user_data" {
  description = "User data shell script for Private EC2"
  type        = string
  default     = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
# git install
sudo yum install git -y
# install nginx
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
sudo systemctl enable nginx
#
# Firewall Rules
#if [[ $(firewall-cmd --state) = 'running' ]]; then
#    YOURPORT=8080
#    PERM="--permanent"
#    SERV="$PERM --service=jenkins"#
#
#    firewall-cmd $PERM --new-service=jenkins
#    firewall-cmd $SERV --set-short="Jenkins ports"
#    firewall-cmd $SERV --set-description="Jenkins port exceptions"
#    firewall-cmd $SERV --add-port=$YOURPORT/tcp
#    firewall-cmd $PERM --add-service=jenkins
#    firewall-cmd --zone=public --add-service=http --permanent
#    firewall-cmd --reload
#fi
EOF
}
