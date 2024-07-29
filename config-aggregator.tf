# AWS Config aggregator

## Organization Aggregator ##
resource "aws_config_configuration_aggregator" "config_aggregator" {
  name = "config-organization-aggregator"

  count = var.aggregation_type == "organization" ? 1 : 0

  organization_aggregation_source {
    role_arn    = aws_iam_role.aggregator_organization[0].arn
    regions     = var.aws_regions
    all_regions = false
  }
}

## Account Aggregator ##
resource "aws_config_configuration_aggregator" "account_config_aggregator" {
  name = "config-account-aggregator"

  count = var.aggregation_type == "account" ? 1 : 0

  account_aggregation_source {
    account_ids = var.account_ids
    regions     = var.aws_regions
    all_regions = false
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

resource "aws_iam_role" "aggregator_organization" {
  count = var.aggregation_type == "organization" ? 1 : 0

  name               = "AWSConfigAggregatorRole"
  assume_role_policy = data.aws_iam_policy_document.aggregator_assume_role.json
}

resource "aws_iam_role_policy_attachment" "aggregator_organization" {
  count = var.aggregation_type == "organization" ? 1 : 0

  role       = aws_iam_role.aggregator_organization[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}
