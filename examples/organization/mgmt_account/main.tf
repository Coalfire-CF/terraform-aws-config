resource "aws_organizations_delegated_administrator" "config" {
  provider          = aws.root
  account_id        = local.mgmt_plane_account_id
  service_principal = "config.amazonaws.com"
}

module "config" {
  source = "git::https://github.com/Coalfire-CF/terraform-aws-config?ref=vX.X.X"

  providers = {
    aws = aws.mgmt
  }

  resource_prefix    = var.resource_prefix
  is_gov             = var.is_gov
  s3_config_arn      = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_config_arn
  s3_config_id       = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_config_id
  config_kms_key_arn = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.config_kms_key_arn
  s3_kms_key_arn     = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_kms_key_arn
  sns_kms_key_id     = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.sns_kms_key_id
  delivery_frequency = "TwentyFour_Hours"
  fedramp_level      = "moderate" # swap to "high" for High clients

  ## Aggregator 
  aws_regions      = var.aws_regions
  account_ids      = local.share_accounts
  aggregation_type = "organization"

  depends_on = [aws_organizations_delegated_administrator.config]
}