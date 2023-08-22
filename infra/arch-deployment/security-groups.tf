# Obtain User's Local Public IP
data "external" "useripaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

# Create Security Groups
#
# security groups for 3 tier architecture: web (public), app (priv), db (priv) layers
# web: allows in-internet, out-internet
# app: allows in-web/db, out-web/db
# db:  allows in-app/web, out-app/web
#
resource "aws_security_group" "web_security_group" {
  name        = "${local.prefix}-${var.aws_region}-web-sg"
  description = "Allow inbound traffic for web tier"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH from internet"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }

  ingress {
    description = "HTTP from internet"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }

  ingress {
    description = "HTTPS from internet"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }

  egress {
    description = "Allow All traffic outbound to Internet"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }
  tags = merge({ Name = "${local.prefix}-${var.aws_region}-web-sg"}, local.common_tags)
}

resource "aws_security_group" "app_security_group" {
  depends_on = [ aws_subnet.private_subnets ]
  name        = "${local.prefix}-${var.aws_region}-app-sg"
  description = "Allow inbound traffic for app tier"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP from VPC"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]
  }

  ingress {
    description = "Allow HTTP in 8080 from VPC"
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]
  }

  ingress {
    description = "Allow HTTPS from VPC"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    #security_groups = [ aws_security_group.db_security_group.id ]
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]
  }

  ingress {
    description = "SSH from VPC"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    #security_groups = [ aws_security_group.web_security_group.id, aws_security_group.db_security_group.id ]
    cidr_blocks = [ aws_vpc.vpc.cidr_block ] #aws_subnet.public_subnets.*.cidr_block
  }

  egress {
    description = "Allow all traffic out to VPC"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ aws_vpc.vpc.cidr_block ] #aws_subnet.public_subnets.*.cidr_block
  }

  # egress {
  #     description = "Allow HTTPS to VPC"
  #     protocol    = "tcp"
  #     from_port   = 443
  #     to_port     = 443
  #     cidr_blocks = [ aws_vpc.vpc.cidr_block ] #aws_subnet.db_subnets.*.cidr_block
  # }
    
  tags = merge({ Name = "${local.prefix}-${var.aws_region}-app-sg"}, local.common_tags)
}

resource "aws_security_group" "db_security_group" {
  depends_on = [ aws_subnet.db_subnets ]
  name        = "${local.prefix}-${var.aws_region}-db-sg"
  description = "Allow inbound traffic for db tier (DynamoDB uses HTTPS)"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP from VPC"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [ aws_vpc.vpc.cidr_block ] #var.private_subnets_cidr
  }

  egress {
    description = "Allow All traffic outbound to VPC"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]  #var.private_subnets_cidr
  }
  tags = merge({ Name = "${local.prefix}-${var.aws_region}-db-sg"}, local.common_tags)
}

# security group for the load balancers
# in: http 80/81 and https from the world
# out: any traffic to the world
resource "aws_security_group" "public_alb_security_group" {
  name        = "${local.prefix}-${var.aws_region}-public-alb-sg"
  description = "SSH/HTTP/HTTPS to public resources"
  vpc_id      = aws_vpc.vpc.id

# Allow HTTP 80 & 81 &HTTPS from anywhere to the alb
  ingress {
    description = "Port 81"
    protocol    = "tcp"
    from_port   = 81
    to_port     = 81
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }

  ingress {
    description = "HTTP (80)"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }

  ingress {
    description = "HTTPS (443)"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }

  egress {
    description = "Allow All traffic outbound"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ var.alltraffic_cidr ]
  }

  tags = merge({ Name = "${local.prefix}-public-alb-sg" }, local.common_tags)

  lifecycle {
    #ignore_changes = [ingress]
    #create_before_destroy = true
  }
}

resource "aws_security_group" "private_alb_security_group" {
  name        = "${local.prefix}-${var.aws_region}-private-alb-sg"
  description = "SSH/HTTP/HTTPS to private resources"
  vpc_id      = aws_vpc.vpc.id

# Allow HTTP 80 & 81 &HTTPS from anywhere to the alb
  ingress {
    description = "HTTP (81)"
    protocol    = "tcp"
    from_port   = 81
    to_port     = 81
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]
    #security_groups = [ aws_security_group.public_alb_security_group.id ]
  }

  ingress {
    description = "HTTP (80)"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]
    #security_groups = [ aws_security_group.public_alb_security_group.id ]
  }

  ingress {
    description = "HTTPS (443)"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]
    #security_groups = [ aws_security_group.public_alb_security_group.id ]
  }

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [ aws_vpc.vpc.cidr_block ]
    #security_groups = [ aws_security_group.public_alb_security_group.id ]
  }

  egress {
    description = "Allow All traffic outbound"
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ var.alltraffic_cidr ]
  }

  tags = merge({ Name = "${local.prefix}-private-alb-sg" }, local.common_tags)

  lifecycle {
    #ignore_changes = [ingress]
    #create_before_destroy = true
  }
}
