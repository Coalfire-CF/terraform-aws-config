module "config" {
  source = "github.com/Coalfire-CF/terraform-aws-config?ref=vX.X.X"

  providers = {
    aws = aws.root
  }

  resource_prefix            = var.resource_prefix
  is_gov                     = var.is_gov
  s3_config_arn              = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_config_arn
  s3_config_id               = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_config_id
  config_kms_key_arn         = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.config_kms_key_arn
  s3_kms_key_arn             = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_kms_key_arn
  sns_kms_key_id             = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.sns_kms_key_id
  conformance_pack_names     = ["Operational-Best-Practices-for-FedRAMP", "Operational-Best-Practices-for-NIST-800-53-rev-5"]
  delivery_frequency         = "TwentyFour_Hours"

  ## Aggregator 
  aws_regions      = var.aws_regions
  account_ids      = local.share_accounts
  aggregation_type = "none"
}