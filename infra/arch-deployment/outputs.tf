# Terraform outputs

# project related outputs
output "prefix" {
  value       = local.prefix
  description = "Deployment objects prefix"
}

output "common_tags" {
  value       = local.common_tags
  description = "Exported common resources tags"
}

output "o_s3_tfstate_bucket_and_key" {
  value = "${var.s3_tfstate_bucket}/${var.s3_tfstate_key}"
}

output "o_dynamo_tflock_table" {
  value = "${var.dynamo_tflock_table}"
}

# VPC id - generated on deployment
output "o_vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "o_public_subnets" {
    description = "List of Public subnets IDs (web layer)"
    value = {
      for subnet in aws_subnet.public_subnets :
        subnet.id => { "name" = subnet.tags.*.Name, "CIDR" = subnet.cidr_block} ##, "Public IP" = subnet.ip }
    }
}

output "o_private_subnets" {
    description = "List of Private subnets IDs (app layer)"
    value = {
      for subnet in aws_subnet.private_subnets :
        subnet.id => { "name" = subnet.tags.*.Name, "CIDR" = subnet.cidr_block }
    }
}

output "o_db_subnets" {
    description = "List of DB Private subnets IDs (db layer)"
    value = {
      for subnet in aws_subnet.db_subnets :
        subnet.id => { "name" = subnet.tags.*.Name, "CIDR" = subnet.cidr_block }
    }
}

output "o_igw_id" {
    #count = length(var.public_subnets_cidr) == 0 ? 0 : 1 # if any public subnet created, we need only 1 
  
    description = "Internet Gateway id"
    value = aws_internet_gateway.internet_gateway.id
}

# output "o_public_alb" {
#   description = "Public ALB properties"
#   value = {
#     for lb in aws_lb.public_alb :
#         lb.id => { "name" = lb.Name, "Public IP" = lb.public_ip, "public DNS" = lb.public_dns, "ARN" = lb.arn }
#   }
# }

# output "o_public_nlb" {
#   description = "Public NLB properties"
#   value = {
#     for lb in aws_lb.public_nlb :
#         lb.id => { "name" = lb.Name, "Public IP" = lb.public_ip, "public DNS" = lb.public_dns, "ARN" = lb.arn }
#   }
# }

output "o_public_instance_connections" {
  description = "Web layer EC2 instance public IP"
  value = {
    for ec2 in aws_instance.web_server :
        ec2.id => { "name" = ec2.tags.*.Name, 
                    "IP" = ec2.public_ip, 
                    "DNS" = ec2.public_dns, 
                    "ARN" = ec2.arn, 
                    "SSH Connection String" = "ssh -i ${local_file.private_key_pem.filename} ec2-user@${ec2.public_ip}" 
                  }
  }
}

# output "o_db_instance_connections" {
#   description = "DB layer EC2 instance public IP"
#   value = {
#     for ec2 in aws_instance.db_server :
#         ec2.id => { "name" = ec2.tags.*.Name, "Private IP" = ec2.private_ip, "Private DNS" = ec2.private_dns, "ARN" = ec2.arn }
#   }
# }

output "o_private_instance_connections" {
  description = "Web layer EC2 instance public IP"
  value = {
    for ec2 in aws_instance.app_server :
        ec2.id => { "name" = ec2.tags.*.Name, "Private IP" = ec2.private_ip, "Private DNS" = ec2.private_dns, "ARN" = ec2.arn }
  }
}

output "o_bastion_host_connections" {
  description = "Bastion Host instance public IP"
  value = {
    for ec2 in aws_instance.bastion_host :
        ec2.id => { "name" = ec2.tags.*.Name, 
                    "IP" = ec2.public_ip, 
                    "DNS" = ec2.public_dns, 
                    "ARN" = ec2.arn, 
                    "SSH Connection String" = "ssh -i ${local_file.private_key_pem.filename} ec2-user@${ec2.public_ip}" 
                  }
  }
}

# output "o_vpc_public_alb_sg" {
#   description = "aws_security_group_id"
#   value = {
#     for sg in aws_security_group.public_alb_security_group :
#         sg.id => { "name" = sg.tags.*.Name, "Id" = sg.id }
#   }
# }
# output "o_vpc_private_alb_sg" {
#   description = "aws_security_group_id"
#   value = {
#     for sg in aws_security_group.private_alb_security_group :
#         sg.id => { "name" = sg.tags.*.Name, "Id" = sg.id }
#   }
# }

output "o_user_local_public_IP" {
  description = "User's local public IP"
  value       = data.external.useripaddr.result.ip
}

# output "o_user_timezone" {
#   description = "detected time zone from the user (for cron triggered events)"
#   value       = data.external.useripaddr.result #var.ec2_timezone
# }