locals {
  # Account and deployment context
  current_account_id = data.aws_caller_identity.current.account_id
  current_region     = data.aws_region.current.id
  partition          = data.aws_partition.current.partition

  # Resource naming
  name_prefix = var.name_prefix != "" ? "${var.name_prefix}-" : ""

  # Common resource tags
  module_tags = {
    Module         = "terraform-aws-config"
    Region         = local.current_region
  }

    # Deployment mode flags
  is_organization_deployment = var.deployment_type == "ORGANIZATION"
  is_standalone_deployment   = var.deployment_type == "STANDALONE"

  combined_tags = merge(local.module_tags, var.tags)
}