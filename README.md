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

## Pre-requisites

  + AWS account with the relevant permissions to perform the creation functions (admin-like preferred)
  + AWSCLI installed (Amazon Command Line interface)
  + Terraform locally installed

## Outputs

  + TBD