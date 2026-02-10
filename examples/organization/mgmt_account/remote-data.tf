terraform {
  backend "s3" {
    bucket       = "client-mgmt-us-gov-west-1-tf-state" # Update to point to management plane TF State bucket
    region       = "us-gov-west-1"
    key          = "client-aws-tgw/us-gov-west-1/aws-config.tfstate" # May need to update path to correctly point to management plane > root account tfstate bucket
    encrypt      = true
    use_lockfile = true
  }
}


data "terraform_remote_state" "fedramp_mgmt_account_setup" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket = "${var.resource_prefix}-${var.aws_region}-tf-state"
    region = var.aws_region
    key    = "${var.resource_prefix}/${var.aws_region}/account-setup.tfstate" # need to confirm
  }
}
