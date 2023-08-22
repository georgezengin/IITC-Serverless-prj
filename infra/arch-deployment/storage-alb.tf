# s3 bucket to connect to endpoint for access from private subnet
resource "aws_s3_bucket" "s3_app_bucket" {
  bucket = "${local.prefix}-${var.s3_app_bucket_name}-${var.aws_region}"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = merge({ Name = "${local.prefix}-${var.s3_app_bucket_name}-${var.aws_region}" }, local.common_tags)
}

#resource "aws_s3_bucket_acl" "remote_state_acl" {
#  bucket = aws_s3_bucket.s3_app_bucket.id
#  acl = "private"
#}

# load balancers for the instances in the public subnets
#
# public alb - for web layer ec2s - api gateways
#
resource "aws_lb" "public_alb" {
  name               = "${local.prefix}-public-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = aws_subnet.public_subnets.*.id
  security_groups    = [ aws_security_group.public_alb_security_group.id ]
  #idle_timeout    = 
  access_logs {    
    bucket = var.s3_app_bucket_name
    prefix = "ALB-logs-pub"  
  }
  tags = merge({ Name = "${local.prefix}--public-alb-${var.aws_region}" }, local.common_tags)

}

# load balancers for the instances in the private subnets
resource "aws_lb_target_group" "public_alb_tg" {
  name        = "${local.prefix}-public-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    enabled  = true
    interval = 30
    path     = "/"
    port     = "traffic-port"
    protocol = "HTTP"
    timeout  = 5
  }
}

#public alb listener forwards to private target group with private instances
resource "aws_lb_listener" "public_alb_listener_http" {
  depends_on = [ aws_lb_target_group.public_alb_tg ]
  count = var.create_private_ec2s ? 1 : 0 # creating if private ec2 instances created
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_alb_tg.arn
    #target_group_arn = aws_lb_target_group.private_alb_tg[0].arn #count.index].arn
    }
}

resource "aws_lb_target_group_attachment" "public_alb_tg_attachment" {
  count            = var.create_public_ec2s ? length(var.public_subnets_cidr) : 0
  target_group_arn = aws_lb_target_group.public_alb_tg.arn
  target_id        = aws_instance.web_server[count.index].id
}

# add private instances to public_alb for access thru public alb
#resource "aws_lb_target_group_attachment" "public_alb_tg_attachment_app" { 
#  count            = var.create_private_ec2s ? length(var.private_subnets_cidr) : 0
#  target_group_arn = aws_lb_target_group.public_alb_tg.arn
#  target_id        = aws_instance.app_server[count.index].id
#}

# Public Network Load Balancer (NLB) Listener for SSH (Port 22) forwarding to private instances
# Public Network Load Balancer (NLB) for SSH forwarding
# resource "aws_lb" "public_nlb" {
#   name               = "${local.prefix}-public-nlb"
#   load_balancer_type = "network"
#   internal           = false
#   subnets            = aws_subnet.public_subnets.*.id
#   #security_groups    = [ aws_security_group.public_alb_security_group.id, aws_security_group.private_alb_security_group.id ]
#   access_logs {    
#     bucket = var.s3_app_bucket_name
#     prefix = "NLB-logs-pub"
#   }
#   tags = merge({ Name = "${local.prefix}-public-nlb-${var.aws_region}" }, local.common_tags)
#}

# resource "aws_lb_listener" "public_listener_ssh" {
#   load_balancer_arn = aws_lb.public_nlb.arn
#   port              = 22
#   protocol          = "TCP"
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.private_nlb_tg.arn
#   }
# }

# # Private Network Load Balancer (NLB) Target Group for the private instances
# resource "aws_lb_target_group" "private_nlb_tg" {
#   name             = "${local.prefix}-priv-nlb-tg"
#   port             = 22
#   protocol         = "TCP"
#   target_type      = "instance"
#   vpc_id           = aws_vpc.vpc.id
# }

# # Attach the private instance to the private ALB target group
# resource "aws_lb_target_group_attachment" "private_instance_attachment_nlb" {
#   count            = var.create_private_ec2s ? length(var.private_subnets_cidr) : 0
#   target_group_arn = aws_lb_target_group.private_nlb_tg.arn
#   target_id        = aws_instance.app_server[count.index].id
# }

# # Create a VPC endpoint for the NLB
# resource "aws_vpc_endpoint" "nlb_endpoint" {
#   vpc_id            = aws_vpc.vpc.id
#   service_name      = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
#   #security_group_ids = [aws_security_group.app_security_group.id]
#   private_dns_enabled = true
#   vpc_endpoint_type = "Interface"
# }

# private alb - for app layer
resource "aws_lb" "private_alb" {
  count              = var.create_private_ec2s ? 1 : 0
  name               = "${local.prefix}-private-alb"
  load_balancer_type = "application"
  internal           = true
  subnets            = aws_subnet.private_subnets.*.id
  security_groups    = [ aws_security_group.private_alb_security_group.id ]
  #idle_timeout       = 
  access_logs {    
    bucket = var.s3_app_bucket_name
    prefix = "ALB-logs-priv"  
  }
  tags = merge({ Name = "${local.prefix}-private-nlb-${var.aws_region}" }, local.common_tags)
}

resource "aws_lb_target_group" "private_alb_tg" {
  count       = var.create_private_ec2s ? 1 : 0
  name        = "${local.prefix}-priv-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  health_check {
    enabled  = true
    protocol = "HTTP"
    interval = 30
    timeout  = 5
    path     = "/"
    port     = "traffic-port"
  }
}

resource "aws_lb_listener" "private-alb-listener_http" {
  count             = var.create_private_ec2s ? 1 : 0
  load_balancer_arn = aws_lb.private_alb[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_alb_tg[0].arn #count.index].arn
  }
}

# Register instances from the public subnet to the target group
resource "aws_lb_target_group_attachment" "private_alb_tg_attachment" {
  count            = var.create_private_ec2s ? length(var.private_subnets_cidr) : 0
  target_group_arn = aws_lb_target_group.private_alb_tg[0].arn
  target_id        = aws_instance.app_server[count.index].id
}