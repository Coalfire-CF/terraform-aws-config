locals {
  # Account and deployment context
  current_account_id = data.aws_caller_identity.current.account_id
  current_region     = data.aws_region.current.id
  partition          = data.aws_partition.current.partition

  # Deployment mode flags
  is_organization_deployment = var.deployment_type == "ORGANIZATION"
  is_standalone_deployment   = var.deployment_type == "STANDALONE"

  # Role-based flags
  is_org_management_account  = local.is_organization_deployment && var.role == "ORG_MANAGEMENT"
  is_delegated_admin_account = local.is_organization_deployment && var.role == "DELEGATED_ADMIN"
  is_member_account          = var.role == "MEMBER"

  # Config Recorder Creation Logic
  should_create_recorder = (
    local.is_standalone_deployment        ## Standalone account (not part of AWS Org)
    || local.is_delegated_admin_account   ## Delegated admin account within the Org
    || local.is_org_management_account    ## Org root / management account
  )

    # Config Recorder Creation Logic
  should_create_delivery_channel = (
    local.is_standalone_deployment        ## Standalone account (not part of AWS Org)
    || local.is_delegated_admin_account   ## Delegated admin account within the Org
    || local.is_org_management_account    ## Org root / management account
  )

  # Resource naming
  name_prefix = var.name_prefix != "" ? "${var.name_prefix}-" : ""

  # Common resource tags
  module_tags = {
    Module         = "terraform-aws-config"
    DeploymentType = var.deployment_type
    AccountRole    = var.role
    Region         = local.current_region
  }

  combined_tags = merge(local.module_tags, var.tags)
}