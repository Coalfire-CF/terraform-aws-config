# Step 1: Organization Admin Delegation

module "organization_admin" {
  source = "./modules/organization-admin"

  count          = local.is_org_management_account && var.delegated_org_account_id != null ? 1 : 0
  org_account_id = var.delegated_org_account_id
  profile        = var.profile
  aws_region     = var.aws_region
}

# Step 2: Config Recorder + Delivery Channel

module "config_baseline" {
  source = "./modules/config"

  aws_regions        = var.aws_regions
  default_aws_region = var.default_aws_region
  resource_prefix    = var.resource_prefix
  is_gov             = var.is_gov
  is_org             = var.is_org
  account_number     = var.account_number
  role_arn           = module.config_baseline.custom_aws_config_role_arn
  s3_bucket_id       = var.s3_config_id
  s3_config_arn      = var.s3_config_arn
  s3_key_prefix      = var.s3_key_prefix
  s3_kms_key_arn     = var.s3_kms_key_arn
  sns_kms_key_id     = var.sns_kms_key_id
  config_kms_key_arn = var.config_kms_key_arn
  delivery_frequency = var.delivery_frequency
  aggregation_type   = var.aggregation_type
  tags               = var.tags
  depends_on         = [module.organization_admin]
}

# Step 3: Conformance Packs (Org or Non-Org)

module "conformance_packs" {
  source = "./modules/conformance-packs"

  aws_region               = var.aws_region
  resource_prefix          = var.resource_prefix
  default_aws_region       = var.default_aws_region
  account_number           = var.account_number
  packs_s3_key             = var.packs_s3_key
  kms_key_id               = var.sns_kms_key_id
  is_org                   = var.is_org
  pack_names               = var.conformance_pack_names
  s3_bucket_id             = var.s3_config_id
  s3_accesslog_bucket_name = var.s3_accesslog_bucket_name
  depends_on               = [module.config_baseline]
}