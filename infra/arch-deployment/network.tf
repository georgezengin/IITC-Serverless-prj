/* This Terraform deployment creates the following resources:
   VPC, Subnet, Internet Gateway, Default Route, Route Association
*/

# Create VPC Resources

resource "aws_vpc" "vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true
  instance_tenancy      = var.vpc_tenancy

  tags = merge({ Name = "${local.prefix}-vpc" }, local.common_tags)
}

#data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_cidr) #== 0 ? var.public_subnets_quantity : length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.vpc.id
  #cidr_block              = var.public_subnets_cidr[count.index]
  cidr_block              = length(var.public_subnets_cidr) == 0 ? cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index+1) : var.public_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.availability_zones.names[count.index]
  map_public_ip_on_launch = true

  tags = merge({ Name = "${local.prefix}-public-subnet-${count.index + 1}-${data.aws_availability_zones.availability_zones.names[count.index]}" }, local.common_tags)
}

resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnets_cidr) #== 0 ? var.private_subnets_quantity : length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.vpc.id
#  cidr_block              = var.private_subnets_cidr[count.index]
  cidr_block              = length(var.private_subnets_cidr) == 0 ? cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index+11) : var.private_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.availability_zones.names[count.index]
  map_public_ip_on_launch = false

  tags = merge({ Name = "${local.prefix}-private-subnet-${count.index + 1}-${data.aws_availability_zones.availability_zones.names[count.index]}" }, local.common_tags)
}

resource "aws_subnet" "db_subnets" {
  count                   = length(var.db_subnets_cidr) #== 0 ? var.private_subnets_quantity : length(var.private_subnets_cidr)
  vpc_id                  = aws_vpc.vpc.id
#  cidr_block              = var.private_subnets_cidr[count.index]
  cidr_block              = length(var.db_subnets_cidr) == 0 ? cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index+21) : var.db_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.availability_zones.names[count.index]
  map_public_ip_on_launch = false

  tags = merge({ Name = "${local.prefix}-db-subnet-${count.index + 1}-${data.aws_availability_zones.availability_zones.names[count.index]}" }, local.common_tags)
}

#
# Internet Gateway
# One provided per VPC, if any public subnets are provided
#
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({ Name = "${local.prefix}-internet-gateway" }, local.common_tags)
}

#
# Route table definition for the Public Subnet
# One is provided for all public subnets to connect to the VPCs IGW, dependent on the number of public CIDRs provided
#
resource "aws_route_table" "vpc_route_table_public" {
  count  = length(var.public_subnets_cidr) == 0 ? 0 : 1 # if any public subnet created, we need only 1 public route table
  vpc_id = aws_vpc.vpc.id

  tags = merge({ Name = "${local.prefix}-rtb-public" }, local.common_tags)
}

resource "aws_route" "vpc_route_internet_access_public" {
  count                   = length(var.public_subnets_cidr) == 0 ? 0 : 1 # if any public subnet created, we need only 1 public route table
  route_table_id          = aws_route_table.vpc_route_table_public[0].id
  destination_cidr_block  = var.alltraffic_cidr
  gateway_id              = aws_internet_gateway.internet_gateway.id
} # end resource

resource "aws_route_table_association" "route_table_assoc_public" {
  count                   = length(var.public_subnets_cidr)
  subnet_id               = aws_subnet.public_subnets[count.index].id
  route_table_id          = aws_route_table.vpc_route_table_public[0].id
}

# Route table definition for the Private Subnet
resource "aws_route_table" "vpc_route_table_private" {
  count      = length(var.private_subnets_cidr) #> 0 ? 1 : 0
  vpc_id     = aws_vpc.vpc.id
  
  tags = merge({ Name = "${local.prefix}-rtb-private-${aws_subnet.private_subnets[count.index].availability_zone}" }, local.common_tags)
}

# resource "aws_route" "vpc_route_instance_access_private" {
#   depends_on = [ aws_vpc_endpoint.s3_vpc_endpoint ]
#   count                   = length(var.private_subnets_cidr)
#   route_table_id          = aws_route_table.vpc_route_table_private[count.index].id
#   destination_cidr_block  = var.vpc_cidr # access only from inside the VPC
#   vpc_endpoint_id         = aws_vpc_endpoint.s3_vpc_endpoint.id # access s3 from private subnet
# }

resource "aws_route_table_association" "route_table_assoc_private" {
  count                   = length(var.private_subnets_cidr)
  subnet_id               = aws_subnet.private_subnets[count.index].id
  route_table_id          = aws_route_table.vpc_route_table_private[count.index].id
}

# Route table definition for the Database Subnet
resource "aws_route_table" "vpc_route_table_db" {
  count      = length(var.db_subnets_cidr) #> 0 ? 1 : 0
  vpc_id     = aws_vpc.vpc.id
  
  tags = merge({ Name = "${local.prefix}-rtb-db-${count.index + 1}-${aws_subnet.db_subnets[count.index].availability_zone}" }, local.common_tags)
}

# resource "aws_route" "vpc_route_instance_access_db" {
#   depends_on = [ aws_vpc_endpoint.dynamodb_connection ]
#   count                   = length(var.db_subnets_cidr)
#   route_table_id          = aws_route_table.vpc_route_table_db[count.index].id
#   destination_cidr_block  = var.vpc_cidr # access only from inside the VPC
#   vpc_endpoint_id         = aws_vpc_endpoint.dynamodb_connection.id
# }

resource "aws_route_table_association" "route_table_assoc_db" {
  count                   = length(var.db_subnets_cidr)
  subnet_id               = aws_subnet.db_subnets.*.id[count.index]
  route_table_id          = aws_route_table.vpc_route_table_db.*.id[count.index]
}

# s3 endpoint for private definition
resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  #route_table_ids   = aws_route_table.vpc_route_table_private.*.id // Add route_table_ids in the aws_vpc_endpoint resource.
  vpc_endpoint_type = "Gateway"

  tags = merge({ Name = "${local.prefix}-s3-vpc-endpoint" }, local.common_tags)
}

# dynamoDB connection to associate to db subnet
resource "aws_vpc_endpoint" "dynamodb_connection" {
    vpc_id = aws_vpc.vpc.id
    service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  #  route_table_ids   = aws_route_table.vpc_route_table_db.*.id // Add route_table_ids in the aws_vpc_endpoint resource.
   policy = <<POLICY
   {
   "Statement": [
       {
       "Action": "*",
       "Effect": "Allow",
       "Resource": "*",
       "Principal": "*"
       }
   ]
   }
   POLICY
    tags = merge({ Name = "${local.prefix}-dynamodb-endpoint" }, local.common_tags)
}