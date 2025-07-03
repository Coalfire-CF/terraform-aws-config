# locals.tf - Local values and conditional logic (copied from GD, needs updating)

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

  combined_tags = merge(local.module_tags, var.tags)
}