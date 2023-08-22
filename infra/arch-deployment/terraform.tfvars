#enter here your AWS credentials if you dont have AWSCLI configured

# uncomment lines below to override local configuration
#aws_profile = "default" # aws profile to use
#   or
#aws_config = {
#    access_key = ""
#    secret_key = ""
#    region = "eu-central-1"
#    profile = "default"
#}

# Customer related tags - used as prefix to provision AWS resources and set in tag Environment
# will be used to name resources deployed as concatenation of next 4 parameters
company = "iitc"
project = "commiitc"
environment = "dev" #pre-release
release_version = "v0-2"

# Set to value wanted for instances
instance_type = "t2.micro"
instance_ami_web = "" # specify AMI-id of image to use for web layer (defaults to latest AMAZON Linux AMI)
instance_ami_app = "" # specify AMI-id of image to use for app layer (defaults to latest AMAZON Linux AMI)

# Specify deployemt region
aws_region = "eu-central-1"

# Specify CIDR block to be used in VPC
vpc_cidr     = "10.1.0.0/16"

# Specify CIDR blocks for subnets to be created 
# in different availability zones 
public_subnets_cidr  = ["10.1.1.0/24",  "10.1.2.0/24"]
private_subnets_cidr = ["10.1.11.0/24", "10.1.12.0/24" ]
db_subnets_cidr      = ["10.1.21.0/24", "10.1.22.0/24"]

create_public_ec2s   = true
create_private_ec2s  = true

# define quantity of private and public subnets (this option will autogenerate CIDRs for each subnet when the CIDRs are not specified, else ignored)
# TODO specify only quantity of public &&|| private subnets and calculate CIDRs from VPCs CIDR
#private_subnets_quantity = 2
#public_subnets_quantity = 2

# Specify if SSH access to public EC2 is is allowed for any IP or limited to initiator's IP
public_access_ssh = "yes"

# Name and path for SSH PEM files to be generated for connection to public EC2 instances
ssh_key = "ssh-key"
ssh_path = "./_scripts-keys/" # can be made to point to ~/.ssh
