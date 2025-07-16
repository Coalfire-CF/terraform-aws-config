## Organization Aggregator ##
resource "aws_config_configuration_aggregator" "org_aggregator" {
  name  = "config-organization-aggregator"
  count = var.aggregation_type == "organization" ? 1 : 0  # Only create if aggregation type is 'organization'

  organization_aggregation_source {
    role_arn    = aws_iam_role.aggregator_organization[0].arn  # IAM role that grants AWS Config org access
    all_regions = true  # Aggregate data from all regions
  }

  depends_on = [aws_iam_role_policy_attachment.aggregator_organization]
}

## Account Aggregator ## 
resource "aws_config_configuration_aggregator" "account_config_aggregator" {
  name  = "config-account-aggregator"
  count = var.aggregation_type == "account" ? 1 : 0  # Only create if aggregation type is 'account'

  account_aggregation_source {
    account_ids = var.account_ids                          # List of AWS accounts to aggregate from
    regions     = var.all_regions ? null : var.aws_regions # Specific regions or null if all
    all_regions = var.all_regions                          # Boolean to enable all-region aggregation
  }
}

## IAM Role for Organization Aggregator ##
data "aws_iam_policy_document" "aggregator_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# IAM role that AWS Config will assume to perform org-level aggregation
resource "aws_iam_role" "aggregator_organization" {
  count              = var.aggregation_type == "organization" ? 1 : 0  # Create only for org aggregation
  name               = "AWSConfigAggregatorRole"
  assume_role_policy = data.aws_iam_policy_document.aggregator_assume_role.json  # Trust policy for AWS Config
}

# Attach AWS managed policy that grants Config permission to read org-level data
resource "aws_iam_role_policy_attachment" "aggregator_organization" {
  count      = var.aggregation_type == "organization" ? 1 : 0
  role       = aws_iam_role.aggregator_organization[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}