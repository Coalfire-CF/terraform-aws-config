terraform {
  backend "s3" {
    bucket       = "client-mgmt-us-gov-west-1-tf-state" # Update to point to management plane TF State bucket
    region       = "us-gov-west-1"
    key          = "client-aws-mgmt/us-gov-west-1/aws-config.tfstate" # May need to update path to correctly point to management plane account tfstate bucket
    encrypt      = true

    assume_role = {
      role_arn     = "arn:aws-us-gov:iam::<mgmt_account_id>:role/OrganizationAccountAccessRole" #update mgmt account id
      session_name = "tf-state-access"
    }
  }
}

data "terraform_remote_state" "fedramp_mgmt_account_setup" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket = "client-mgmt-${var.aws_region}-tf-state"
    region = var.aws_region
    key    = "client-mgmt/${var.aws_region}/account-setup.tfstate" 
  }
}