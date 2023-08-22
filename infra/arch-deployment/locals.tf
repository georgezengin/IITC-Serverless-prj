locals {
    l_current_date    = formatdate("YYYY-MM-DD", timestamp())
    l_current_time    = formatdate("HH-MM-SS", timestamp())

    l_aws_access_key  = var.aws_access_key != "" ? var.aws_access_key : lookup(var.env, "AWS_ACCESS_KEY_ID",     lookup(var.aws_config, "aws_access_key_id", null))
    l_aws_secret_key  = var.aws_secret_key != "" ? var.aws_secret_key : lookup(var.env, "AWS_SECRET_ACCESS_KEY", lookup(var.aws_config, "aws_secret_access_key", null))
    l_aws_region      = var.aws_region     != "" ? var.aws_region     : lookup(var.env, "AWS_REGION",            lookup(var.aws_config, "aws_region",     "eu-central-1"))
    l_aws_profile     = var.aws_profile    != "" ? var.aws_profile    : lookup(var.env, "AWS_PROFILE",           lookup(var.aws_config, "aws_profile",    "default"))

    prefix            = "${var.project}-${var.environment}-${var.release_version}"
    short_prefix      = "${var.project}-${var.environment}"
    ssh_project_key   = "${local.prefix}-${var.ssh_key}"
    # bucket_name       = "${local.prefix}-s3-bucket"
    # state_file_name   = "${local.prefix}.terraform.tfstate" #"terraform-${local.current_date}-${local.current_time}.tfstate"
    # remote_state_name = "/${local.prefix}/tf-remote-state-bucket"

    # tf_locks_table    = "${local.prefix}-tf-locks-table"
    # tf_locks_tbl_arn  = "/${local.prefix}/tf-locks-table-arn"

    ssm_prefix        = "${var.company}/${var.project}/${var.environment}/${var.release_version}/terraform"

    common_tags = {
        Company       = var.company,
        Project       = var.project,
        Env           = var.environment,
        Version       = var.release_version,
        DeployedBy    = "Terraform"
    }

    default_availability_zones = data.aws_availability_zones.available_zones.names

    # list of files to transfer to web layer instances and their destination
    # web_file_map = {
    #     "./_scripts-keys/ec2-web-setup.sh"  = "/home/ec2-user/ec2-web-setup.sh",
    #     "${var.ssh_path}${local.ssh_project_key}.zip" = "/home/ec2-user/${local.ssh_project_key}.zip",
    #     "./_app/angular-cognito-app.zip" = "/home/ec2-user/angular-cognito-app.zip"
    # }

    # # list of files to transfer to app layer instances and their destination
    # app_file_map = {
    #     "./_scripts-keys/ec2-web-setup.sh"  = "/home/ec2-user/ec2-app-setup.sh",
    #     "${var.ssh_path}${local.ssh_project_key}.zip" = "/home/ec2-user/${local.ssh_project_key}.zip",
    #     "./_app/angular-cognito-app.zip" = "/home/ec2-user/angular-cognito-app.zip"
    # }


    web_remote_exec = [ # list of commands to execute in web layer EC2s on deployment
        #"unzip /home/ec2-user/${local.ssh_project_key}.zip",
        #"sudo chmod 400 /home/ec2-user/${local.ssh_project_key}.pem",
        #"sudo cat /home/ec2-user/${local.ssh_project_key}.pem >> ~/.ssh/authorized_keys",
        #"sudo mv *.pem .ssh/",
        "chmod +x /home/ec2-user/ec2-web-setup.sh install-nodejs.sh",
        "mkdir .install.logdir",
        "mv * .install.logdir",
        "/home/ec2-user/.install.logdir/ec2-web-setup.sh 2>&1 | tee /home/ec2-user/.install.logdir/ec2-setup.log",  # Redirect script output to a log file
    ]

    app_remote_exec = [ # empty that defaults to web_remote_exec
        #"unzip /home/ec2-user/${local.ssh_project_key}.zip",
        #"sudo chmod 400 /home/ec2-user/${local.ssh_project_key}.pem",
        #"sudo cat /home/ec2-user/${local.ssh_project_key}.pem >> ~/.ssh/authorized_keys",
        #"sudo mv *.pem .ssh/",
        "chmod +x /home/ec2-user/ec2-app-setup.sh install-nodejs.sh",
        "mkdir .install.logdir",
        "mv * .install.logdir",
        "/home/ec2-user/.install.logdir/ec2-app-setup.sh 2>&1 | tee /home/ec2-user/.install.logdir/ec2-setup.log",  # Redirect script output to a log file
    ]
}
