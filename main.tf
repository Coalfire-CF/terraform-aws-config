# Step 1: Register Delegated Admin (Run only from Org Management Account)

module "organization_admin" {
  source = "./modules/organization-admin"

  count              = local.is_org_management_account && var.delegated_org_account_id != null ? 1 : 0
  org_account_id     = var.delegated_org_account_id
  profile            = var.profile
  aws_region         = var.aws_region
}

# Step 2: Config Baseline (Recorder + Delivery Channel)

module "config_baseline" {
  source = "./modules/config"

  count                   = local.is_delegated_admin_account || local.is_member_account ? 1 : 0

  create_config_in_admin  = local.is_delegated_admin_account && var.create_config_in_admin
  create_config_recorder  = local.should_create_recorder
  create_delivery_channel = local.should_create_delivery_channel

  # Multi-region setup
  aws_regions        = var.aws_regions
  default_aws_region = var.default_aws_region

  # Resource naming + metadata
  resource_prefix    = var.resource_prefix != null ? var.resource_prefix : ""
  is_gov             = var.is_gov
  is_org             = var.is_org
  organization_id    = var.organization_id
  account_number     = var.account_number

  # Optional IAM Role passed in if using external role module
  role_arn           = var.config_role_arn

  # S3 / KMS / SNS
  s3_bucket_id       = var.s3_config_id
  s3_config_arn      = var.s3_config_arn
  s3_key_prefix      = var.s3_key_prefix
  s3_kms_key_arn     = var.s3_kms_key_arn
  create_sns_topic   = var.create_sns_topic
  sns_kms_key_id     = var.sns_kms_key_id
  config_kms_key_arn = var.config_kms_key_arn

  # Other
  delivery_frequency = var.delivery_frequency
  aggregation_type   = var.aggregation_type
  tags               = var.tags

  depends_on         = [module.organization_admin]
}


# Step 3: Conformance Packs (Only in delegated admin or standalone)

module "conformance_packs" {
  source = "./modules/conformance-packs"

  count = local.is_delegated_admin_account || local.is_member_account ? 1 : 0

  aws_region               = var.aws_region
  default_aws_region       = var.default_aws_region
  resource_prefix          = var.resource_prefix
  account_number           = var.account_number
  is_org                   = var.is_org
  organization_id          = var.organization_id

  # Conformance packs list and source bucket
  pack_names               = var.conformance_pack_names
  packs_s3_key             = var.packs_s3_key
  s3_bucket_id             = var.s3_config_id
  s3_accesslog_bucket_name = var.s3_accesslog_bucket_name

  kms_key_id               = var.sns_kms_key_id

  depends_on               = [module.config_baseline]
}