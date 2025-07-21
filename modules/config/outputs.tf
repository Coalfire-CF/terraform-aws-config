## Config Outputs ##

# Output the name of the configuration recorder
output "config_recorder_name" {
  description = "The name of the AWS Config configuration recorder"
  value       = aws_config_configuration_recorder.config.name
}

# Output the name of the delivery channel used by Config
output "delivery_channel_name" {
  description = "The name of the AWS Config delivery channel"
  value       = aws_config_delivery_channel.config.name
}

# Output the ID (name) of the S3 bucket used for Config snapshot delivery
output "config_delivery_bucket" {
  description = "The S3 bucket used to deliver AWS Config snapshots"
  value       = var.s3_bucket_id
}

# Output the ARN of the SNS topic used for Config notifications
output "sns_topic_arn" {
  description = "ARN of the SNS topic used by AWS Config. Null if topic is not created."
  value       = var.create_sns_topic ? aws_sns_topic.config_delivery[0].arn : null
}

## Config Aggregator Outputs ##

# Output the name of the organization-level aggregator (if it exists)
output "org_aggregator_name" {
  description = "The name of the AWS Config organization-level aggregator"
  value       = try(aws_config_configuration_aggregator.org_aggregator[0].name, null)
}

# Output the name of the account-level aggregator (if it exists)
output "account_aggregator_name" {
  description = "The name of the AWS Config account-level aggregator"
  value       = try(aws_config_configuration_aggregator.account_config_aggregator[0].name, null)
}

# Output the ARN of the IAM role used by the org-level aggregator (if it exists)
output "aggregator_role_arn" {
  description = "ARN of the IAM role used by the Config organization-level aggregator"
  value       = try(aws_iam_role.aggregator_organization[0].arn, null)
}

## IAM Outputs ##

# Output the name of the custom IAM role used by AWS Config
output "config_iam_role_name" {
  description = "Name of the custom IAM role used by AWS Config"
  value       = aws_iam_role.custom_aws_config_role.name
}

# Redundant output: same as config_iam_role_arn - confirm if/where this output is needed
output "custom_aws_config_role_arn" {
  description = "ARN of the custom IAM role used by AWS Config"
  value       = aws_iam_role.custom_aws_config_role.arn
}

# Output the ARN of the custom IAM role used by AWS Config
output "config_iam_role_arn" {
  description = "ARN of the custom IAM role used by AWS Config"
  value       = aws_iam_role.custom_aws_config_role.arn
}

# Output the IAM role ID of the Config role
output "config_iam_role_id" {
  description = "ID of the custom IAM role used by AWS Config"
  value       = aws_iam_role.custom_aws_config_role.id
}

# Output the name of the inline policy granting S3 permissions to the Config IAM role
output "s3_policy_name" {
  description = "The name of the inline S3 policy attached to the Config IAM role"
  value       = aws_iam_role_policy.s3_config_role_policy.name
}

# Output the name of the inline policy granting KMS permissions to the Config IAM role
output "kms_policy_name" {
  description = "The name of the inline KMS policy attached to the Config IAM role"
  value       = aws_iam_role_policy.kms_config_role_policy.name
}