output "config_recorder_name" {
  description = "The name of the AWS Config configuration recorder"
  value       = aws_config_configuration_recorder.default.name
}

output "delivery_channel_name" {
  description = "The name of the AWS Config delivery channel"
  value       = aws_config_delivery_channel.default.name
}

output "config_aggregator_name" {
  description = "The name of the AWS Config organization-level aggregator"
  value       = aws_config_configuration_aggregator.org_aggregator.name
}

output "aggregator_role_arn" {
  description = "ARN of the IAM role used by the Config aggregator"
  value       = aws_iam_role.aggregator.arn
}

output "config_delivery_bucket" {
  description = "The S3 bucket used to deliver AWS Config snapshots"
  value       = var.s3_bucket_id
}

