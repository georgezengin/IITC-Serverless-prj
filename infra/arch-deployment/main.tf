/* This Terraform deployment creates the following resources:
   VPC, Subnet, Internet Gateway, Route table, Security Group, 
   SSH Key and EC2 with Git, Java, Python, Docker, Ansible & Jenkins installed 
*/

/*
module "network" {
  source = "./modules/network"
  # pass project variables from terraform.tfvars
  environment       = var.environment
  aws_region        = var.aws_region
  avail_zones       = var.avail_zones
}

module "ec2" {
  source = "./modules/ec2"
  environment       = var.environment
  instance_type     = var.instance_type
  aws_region        = var.aws_region
  avail_zones       = var.avail_zones
  vpc_id            = module.network.o_vpc_id
  public_subnet_id  = module.network.o_subnet_id
  public_access_ssh = var.public_access_ssh
  ssh_key           = var.ssh_key
  ssh_path          = var.ssh_path
  email_addr_sns    = var.email_addr_sns
} */

data "aws_availability_zones" "available_zones" {
  state = "available"
}
