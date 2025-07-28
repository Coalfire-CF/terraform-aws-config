locals {

  is_org_management_account  = var.account_number == var.org_management_account_id
  is_delegated_admin_account = var.account_number == var.delegated_org_account_id
  is_member_account          = !local.is_org_management_account && !local.is_delegated_admin_account

  should_create_recorder      = var.enable_config && (local.is_member_account || local.is_delegated_admin_account)
  should_create_delivery_channel = var.enable_config && (local.is_member_account || local.is_delegated_admin_account)

  # Account and deployment context
  current_account_id = data.aws_caller_identity.current.account_id
  current_region     = data.aws_region.current.id
  partition          = data.aws_partition.current.partition

  # Deployment mode flags
  is_organization_deployment = var.deployment_type == "ORGANIZATION"
  is_standalone_deployment   = var.deployment_type == "STANDALONE"

#   # Role-based flags
#   is_org_management_account  = local.is_organization_deployment && var.role == "ORG_MANAGEMENT"
#   is_delegated_admin_account = local.is_organization_deployment && var.role == "DELEGATED_ADMIN"
#   is_member_account          = var.role == "MEMBER"

#   # Resource naming
#  resource_prefix = var.resource_prefix != "" ? "${var.resource_prefix}-" : ""

  # Common resource tags
  module_tags = {
    Module         = "terraform-aws-config"
    DeploymentType = var.deployment_type
    AccountRole    = var.role
    Region         = local.current_region
  }

  combined_tags = merge(local.module_tags, var.tags)
}