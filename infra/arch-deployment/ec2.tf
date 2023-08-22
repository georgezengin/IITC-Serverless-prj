/* This Terraform deployment creates the following resources:
    EC2 Instances and related resources  */

# Lookup Amazon Linux Image
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

# Create SSH Keys for EC2 Remote Access
resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "local_file" "private_key_pem" {
  depends_on = [ aws_key_pair.generated, tls_private_key.generated ]
  content         = tls_private_key.generated.private_key_pem
  filename        = "${var.ssh_path}${local.ssh_project_key}.pem"
  file_permission = "0400"
}

resource "local_file" "public_key_pem" {
  depends_on = [ local_file.private_key_pem ]
  content         = tls_private_key.generated.public_key_pem
  filename        = "${var.ssh_path}${local.ssh_project_key}.pem.pub"
  file_permission = "0400"
}

data "archive_file" "pem_zip" {
  depends_on = [ local_file.public_key_pem ]
  type        = "zip"
  source_file = "${var.ssh_path}${local.ssh_project_key}.pem"
  output_path = "${var.ssh_path}${local.ssh_project_key}.zip"
}

resource "aws_key_pair" "generated" {
  key_name   = local.ssh_project_key #var.ssh_key
  public_key = tls_private_key.generated.public_key_openssh
  tags = merge({ Name = "${local.ssh_project_key}-aws-key-pair" }, local.common_tags)
}

# Create EC2 Instance
resource "aws_instance" "web_server" { # web server contains frontend app
  count                       = var.create_public_ec2s ? length(var.public_subnets_cidr) : 0
  ami                         = var.instance_ami_web == "" ? data.aws_ami.amazon_linux_2.id : var.instance_ami_web
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.generated.key_name
  subnet_id                   = aws_subnet.public_subnets[count.index].id
  security_groups             = [aws_security_group.web_security_group.id]
  associate_public_ip_address = true

  # user_data                   =  "${file("./ansible-install.sh")}"
  
  connection {
    user        = "ec2-user"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.host_id #public_ip
    type        = "ssh"
    password    = ""
  }

  #Use the "file" provisioner with the appropriate source and destination.
  # provisioner "file" {
  #   for_each = local.web_file_map
  #   source      = "${each.key}"
  #   destination = "${each.value}"
  #   connection {
  #     user        = "ec2-user"
  #     private_key = tls_private_key.generated.private_key_pem
  #     host        = self.public_ip
  #     type        = "ssh"
  #     password    = ""
  #   }
  # }

  provisioner "file" {
    source      = "./_scripts-keys/ec2-web-setup.sh"  # Path to your bash script file
    destination = "/home/ec2-user/ec2-web-setup.sh"
    connection {
      user        = "ec2-user"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
      type        = "ssh"
      password    = ""
    }
  }

  provisioner "file" {
    source      = "./_scripts-keys/nginx.conf"  # Path to your bash script file
    destination = "/home/ec2-user/nginx.conf"
    connection {
      user        = "ec2-user"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
      type        = "ssh"
      password    = ""
    }
  }

  provisioner "file" {
    source      = "${var.ssh_path}${local.ssh_project_key}.zip" #${local_file.private_key_pem.filename}"
    destination = "/home/ec2-user/${local.ssh_project_key}.zip"
    connection {
      user        = "ec2-user"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
      type        = "ssh"
      password    = ""
    }
  }

  provisioner "file" {
    source      = "./_app/angular-cognito-app.zip" #${local_file.private_key_pem.filename}"
    destination = "/home/ec2-user/angular-cognito-app.zip"
    connection {
      user        = "ec2-user"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
      type        = "ssh"
      password    = ""
    }
  }

  provisioner "remote-exec" {
    inline = local.web_remote_exec
    connection {
      user        = "ec2-user"
      private_key = tls_private_key.generated.private_key_pem
      host        = self.public_ip
      type        = "ssh"
      password    = ""
    }
  }
   
  tags = merge({ Name = "${local.prefix}-web-server-${aws_subnet.public_subnets[count.index].availability_zone}" }, local.common_tags)

  lifecycle {
    ignore_changes = [ security_groups ]
    #create_before_destroy = true
  }
}

resource "aws_instance" "app_server" { # web server contains backend server
  depends_on = [ aws_instance.bastion_host ]
  count                       = var.create_private_ec2s ? length(var.private_subnets_cidr) : 0
  ami                         = var.instance_ami_app == "" ? data.aws_ami.amazon_linux_2.id : var.instance_ami_app
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.generated.key_name
  subnet_id                   = aws_subnet.private_subnets[count.index].id
  security_groups             = [aws_security_group.app_security_group.id]
  associate_public_ip_address = false
  #user_data                   = var.ec2_private_user_data 
  
  # connection {
  #     type        = "ssh"
  #     agent       = true
  #     #host        = aws_lb.public_nlb.dns_name  # Use the public ALB's DNS name
  #     host        = self.private_ip #bastion_host[0].public_ip  # Use the bastion host's public IP
  #     user        = "ec2-user"  # Replace with the username of the private instance
  #     private_key = tls_private_key.generated.private_key_pem
  #     password    = ""
  #     #private_key  = file("~/.ssh/your_key.pem")  # Replace with the path to your private key
  #     timeout      = "2m"
  # }

  # provisioner "file" {
  #   source      = "./_scripts-keys/ec2-app-setup.sh"  # Path to your bash script file
  #   destination = "/home/ec2-user/ec2-app-setup.sh"
  #   # connection {
  #   #   type        = "ssh"
  #   #   agent       = true
  #   #   #host        = aws_lb.public_nlb.dns_name  # Use the public ALB's DNS name
  #   #   host        = self.private_ip #bastion_host[0].public_ip  # Use the bastion host's public IP
  #   #   user        = "ec2-user"  # Replace with the username of the private instance
  #   #   private_key = tls_private_key.generated.private_key_pem
  #   #   password    = ""
  #   #   #private_key  = file("~/.ssh/your_key.pem")  # Replace with the path to your private key
  #   #   timeout      = "2m"
  #   # }
  # }

  # provisioner "file" {
  #   source      = "./_scripts-keys/nginx.conf"  # Path to your bash script file
  #   destination = "/home/ec2-user/nginx.conf"
  #   #  connection {
  #   #   type        = "ssh"
  #   #   agent       = true
  #   #   #host        = aws_lb.public_nlb.dns_name  # Use the public ALB's DNS name
  #   #   host        = self.private_ip #bastion_host[0].public_ip  # Use the bastion host's public IP
  #   #   user        = "ec2-user"  # Replace with the username of the private instance
  #   #   private_key = tls_private_key.generated.private_key_pem
  #   #   password    = ""
  #   #   #private_key  = file("~/.ssh/your_key.pem")  # Replace with the path to your private key
  #   #   timeout      = "2m"
  #   # }
  # }


  # provisioner "file" {
  #   source      = "${var.ssh_path}${local.ssh_project_key}.zip" #${local_file.private_key_pem.filename}"
  #   destination = "/home/ec2-user/${local.ssh_project_key}.zip"
  #   # connection {
  #   #   type        = "ssh"
  #   #   agent       = true
  #   #   #host        = aws_lb.public_nlb.dns_name  # Use the public ALB's DNS name
  #   #   host        = self.private_ip #bastion_host[0].public_ip  # Use the bastion host's public IP
  #   #   user        = "ec2-user"  # Replace with the username of the private instance
  #   #   private_key = tls_private_key.generated.private_key_pem
  #   #   password    = ""
  #   #   #private_key  = file("~/.ssh/your_key.pem")  # Replace with the path to your private key
  #   #   timeout      = "2m"
  #   # }
  # }

  # provisioner "file" {
  #   source      = "./_app/angular-cognito-app.zip" #${local_file.private_key_pem.filename}"
  #   destination = "/home/ec2-user/angular-cognito-app.zip"
  #   # connection {
  #   #   type        = "ssh"
  #   #   agent       = true
  #   #   #host        = aws_lb.public_nlb.dns_name  # Use the public ALB's DNS name
  #   #   host        = self.private_ip #bastion_host[0].public_ip  # Use the bastion host's public IP
  #   #   user        = "ec2-user"  # Replace with the username of the private instance
  #   #   private_key = tls_private_key.generated.private_key_pem
  #   #   password    = ""
  #   #   #private_key  = file("~/.ssh/your_key.pem")  # Replace with the path to your private key
  #   #   timeout      = "2m"
  #   # }
  # }

  # provisioner "remote-exec" {
  #   inline = local.app_remote_exec
  #   # connection {
  #   #   type        = "ssh"
  #   #   agent       = true
  #   #   #host        = aws_lb.public_nlb.dns_name  # Use the public ALB's DNS name
  #   #   host        = self.private_ip #bastion_host[0].public_ip  # Use the bastion host's public IP
  #   #   user        = "ec2-user"  # Replace with the username of the private instance
  #   #   private_key = tls_private_key.generated.private_key_pem
  #   #   password    = ""
  #   #   #private_key  = file("~/.ssh/your_key.pem")  # Replace with the path to your private key
  #   #   timeout      = "2m"
  #   # }
  # }
    
  tags = merge({ Name = "${local.prefix}-app-server-${aws_subnet.private_subnets[count.index].availability_zone}" }, local.common_tags)

  lifecycle {
    #ignore_changes = [ security_groups ]
    #create_before_destroy = true
    prevent_destroy = true
  }
}

# Create a bastion host in the public subnet
resource "aws_instance" "bastion_host" {
  count                       = var.create_private_ec2s ? 1 : 0
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.generated.key_name
  subnet_id                   = aws_subnet.public_subnets[0].id
  security_groups             = [aws_security_group.public_bastion_sg.id]
  associate_public_ip_address = true  # Allocate a public IP to the bastion host
  vpc_security_group_ids      = [aws_security_group.public_bastion_sg.id]
  lifecycle {
    #ignore_changes = [ security_groups ]
    #create_before_destroy = true
  }
  tags = merge({ Name = "${local.prefix}-bastion-host-${aws_subnet.private_subnets[count.index].availability_zone}" }, local.common_tags)

}

# Modify the security group of the private instance to allow SSH traffic from the bastion host
resource "aws_security_group" "public_bastion_sg" {
  name        = "${local.prefix}-public-bastion-sg"
  description = "Security group for bastion host (public instance)"
  vpc_id      = aws_vpc.vpc.id

  # Allow SSH traffic from your local IP (adjust the CIDR block as needed)
  ingress {
    description = "SSH access from local machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }

  ingress {
    description = "HTTP access from local machine"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.public_access_ssh == "yes" ? [ var.alltraffic_cidr ] : [ "${data.external.useripaddr.result.ip}/32" ]
  }

  # Allow all outbound traffic to the private subnets in the VPC
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.app_security_group.id]
  }
}

  # You can add additional ingress/egress rules as needed for your use case.
resource "aws_security_group_rule" "private_ssh_from_bastion" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  security_group_id = aws_security_group.app_security_group.id
  source_security_group_id = aws_security_group.public_bastion_sg.id
}
