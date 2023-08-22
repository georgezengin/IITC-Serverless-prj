<!-- BEGIN_TF_DOCS -->

# Project Introduction:

You would like to build web application for a new company that can be accessed from anywhere using http.

## Basic flow
1. A user browses to the frontend (API Gateway) and gets authenticated with username and password (Cognito)
2. If authenticated successfully, the service will write the user information (username and date and time) into a database (DynamoDB)
3. The service will create a file in an S3 bucket with the name of the user – The content of the file will be the current time
4. The service will write a log of failed and successful authentication to CloudWatch
5. The service will then write a message back to the user saying “hello, “ with the name of the user

## Architecture diagram of this solution

![Screenshot](_images/architecture-diagram.jpg)

  ### Instructions:
  - Clone this project in a folder of your choice in a Linux session.
    ```shell
    git clone https://github.com/georgezengin/TF-EC2-Ans-Dkr.git
    ```

  - Customize the project specific parameters in file *'terraform.tfvars'* (defaults to *eu-central-1* region and *eu-central-1a* zone).
    Use this file to customize the project name, the region, availability_zones, VPC CIDR, subnet CIDRs, ssh key file name, email address.

  - Environment Variables (optional)
    This is needed if you havent configured a user in AWSCLI with the *'aws configure'* command.
    - AWS_ACCESS_KEY_ID    : your user's Access Key ID
    - AWS_SECRET_ACCESS_KEY: your user's Secret access key.
    ```shell
    export AWS_ACCESS_KEY_ID=<your_access_key_id>
    export AWS_SECRET_ACCESS_KEY=<your_secret_key>
    ```
    Alternatively, the AWS credentials can be added to the *'terraform.tfvars'* file, if preferred.

  - On a terminal session, issue the following commands in the project's directory:
    ```shell  
    terraform init
    terraform validate
    terraform plan
    terraform apply  # (enter yes when prompted to apply changes)
    ```

    On completion, the *'terraform apply'* command will produce a list of outputs among those the following:
    - Public IP of the created instance
    - CLI string to be used for ssh connection to the instance.
      Just copy this command and execute it in your shell to connect to it.
    (see screen outputs at bottom of this file)

  ## When finished - don't forget to delete the deployed resources to avoid unnecessary charges
  For that purpose, run the following command on the command line of your deployment terminal (not the EC2 instance shell)
  ```shell
  terraform destroy
  ```

## Usage of the deployed resources in this architecture

  + EC2 instance

  Use your terminal to SSH into the EC2 public IP using the generated PEM file in the project root directory.
  Use the command line provided as output of the terraform script for SSH connection. 
    
  ![Screenshot](_images/ssh-string.png)

  + Jenkins

  Connect to the Jenkins GUI on the EC2 public IP at port 8080 using HTTP in your browser.
  Ctrl-click at the link in the outputs will take you straight to it.
    
  ![Screenshot](_images/jenkins-GUI.png)

## Pre-requisites

  + AWS account with the relevant permissions to perform the creation functions (admin-like preferred)
  + AWSCLI installed (Amazon Command Line interface)
  + Terraform locally installed

## Outputs

  + Sample screenshot after *terraform apply* ends

    ![Screenshot](_images/finish-script.jpg)

  + Sample screenshot of outputs generated
    (includes ssh connection string and Jenkins GUI URL)

    ![Screenshot](_images/list-of-outputs.jpg)

  + Session opened using connection string.
  
    A hidden directory [.install-jenkins] is created by the installation script, inside of it you can find the ansible yml file, the 
    installation script and the log file at the time of deployment.

    ![Screenshot](_images/ssh-session.png)

  + Sample of Mail Notification on Instance Start/Stop

    ![Screenshot](_images/mail-notification.jpg)

 
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.55.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.3.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |
## Resources

| Name | Type |
|------|------|
| [aws_instance.app_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.web_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.generated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_lb.private_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb.public_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_target_group.private_alb_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.public_alb_tg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.private_alb_tg_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.public_alb_tg_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route.vpc_route_instance_access_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpc_route_instance_access_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.vpc_route_internet_access_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.vpc_route_table_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.vpc_route_table_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.vpc_route_table_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.route_table_assoc_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.route_table_assoc_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.route_table_assoc_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.s3_app_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.remote_state_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_security_group.alb_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.app_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.db_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.web_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.db_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.dynamodb_connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [local_file.private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.generated](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.availability_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_availability_zones.available_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [external_external.useripaddr](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_common_tags"></a> [common\_tags](#output\_common\_tags) | Exported common resources tags |
| <a name="output_o_db_subnets"></a> [o\_db\_subnets](#output\_o\_db\_subnets) | List of DB Private subnets IDs |
| <a name="output_o_igw_id"></a> [o\_igw\_id](#output\_o\_igw\_id) | Internet Gateway id |
| <a name="output_o_private_subnets"></a> [o\_private\_subnets](#output\_o\_private\_subnets) | List of Private subnets IDs |
| <a name="output_o_public_subnets"></a> [o\_public\_subnets](#output\_o\_public\_subnets) | List of Public subnets IDs |
| <a name="output_o_vpc_id"></a> [o\_vpc\_id](#output\_o\_vpc\_id) | VPC ID |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | Exported common resources prefix |
<!-- END_TF_DOCS -->
