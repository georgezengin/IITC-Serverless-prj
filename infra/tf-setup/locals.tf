locals {
    l_current_date   = formatdate("YYYY-MM-DD", timestamp())
    l_current_time   = formatdate("HH-MM-SS", timestamp())
    l_aws_access_key = var.aws_access_key != "" ? var.aws_access_key : lookup(var.env, "AWS_ACCESS_KEY_ID",     lookup(var.aws_config, "access_key", null))
    l_aws_secret_key = var.aws_secret_key != "" ? var.aws_secret_key : lookup(var.env, "AWS_SECRET_ACCESS_KEY", lookup(var.aws_config, "secret_key", null))
    l_aws_region     = var.aws_region     != "" ? var.aws_region     : lookup(var.env, "AWS_REGION",            lookup(var.aws_config, "region",     "eu-central-1"))
    l_aws_profile    = var.aws_profile    != "" ? var.aws_profile    : lookup(var.env, "AWS_PROFILE",           lookup(var.aws_config, "profile",    "default"))

    prefix            = "${var.project}-${var.environment}-${var.release_version}"
    bucket_name       = "${local.prefix}-s3"
    state_file_name   = "${local.prefix}.terraform.tfstate" #-${local.l_current_date}-${local.l_current_time}.tfstate"
    remote_state_name = "/${local.prefix}/tf-remote-state-bucket"
    tf_locks_table    = "${local.prefix}-tf-locks-table"
    tf_locks_tbl_arn  = "/${local.prefix}/tf-locks-table-arn"
    ssm_prefix = "${var.company}/${var.project}/${var.environment}/${var.release_version}/terraform"

    common_tags = {
        Company    = var.company,
        Project    = var.project,
        Env        = var.environment,
        Version    = var.release_version,
        DeployedBy = "Terraform"
    }
}
