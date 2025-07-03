# data.tf - Data sources for the GuardDuty module

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# Get organization details if in organization context
data "aws_organizations_organization" "current" {
  count = local.is_organization_deployment ? 1 : 0
}