## Config Outputs ##

output "config_recorder_name" {
  description = "The name of the AWS Config configuration recorder"
  value       = aws_config_configuration_recorder.this.name
}

output "delivery_channel_name" {
  description = "The name of the AWS Config delivery channel"
  value       = aws_config_delivery_channel.this.name
}

output "config_delivery_bucket" {
  description = "The S3 bucket used to deliver AWS Config snapshots"
  value       = var.s3_bucket_id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used by AWS Config"
  value       = aws_sns_topic.config_delivery.arn
}

## Config Aggregator Outputs ##

output "org_aggregator_name" {
  description = "The name of the AWS Config organization-level aggregator"
  value       = try(aws_config_configuration_aggregator.org_aggregator[0].name, null)
}

output "account_aggregator_name" {
  description = "The name of the AWS Config account-level aggregator"
  value       = try(aws_config_configuration_aggregator.account_config_aggregator[0].name, null)
}

output "aggregator_role_arn" {
  description = "ARN of the IAM role used by the Config organization-level aggregator"
  value       = try(aws_iam_role.aggregator_organization[0].arn, null)
}

## IAM Outputs ##

output "config_iam_role_name" {
  description = "Name of the custom IAM role used by AWS Config"
  value       = aws_iam_role.custom_aws_config_role.name
}

output "config_iam_role_arn" {
  description = "ARN of the custom IAM role used by AWS Config"
  value       = aws_iam_role.custom_aws_config_role.arn
}

output "config_iam_role_id" {
  description = "ID of the custom IAM role used by AWS Config"
  value       = aws_iam_role.custom_aws_config_role.id
}

output "s3_policy_name" {
  description = "The name of the inline S3 policy attached to the Config IAM role"
  value       = aws_iam_role_policy.s3_config_role_policy.name
}

output "kms_policy_name" {
  description = "The name of the inline KMS policy attached to the Config IAM role"
  value       = aws_iam_role_policy.kms_config_role_policy.name
}

output "custom_aws_config_role_arn" {
  description = "ARN of the custom IAM role used by AWS Config"
  value       = aws_iam_role.custom_aws_config_role.arn
}