# Create the AWS Config recorder to track configuration changes
resource "aws_config_configuration_recorder" "config" {
  count = var.create_config_recorder ? 1 : 0
  name     = "${var.resource_prefix}-config"         # Custom name for recorder
  role_arn = aws_iam_role.custom_aws_config_role.arn # IAM role AWS Config assumes

  recording_group {
    all_supported                 = true # Record all supported resource types
    include_global_resource_types = true # Include global resources (e.g., IAM, Route 53)
  }
}

# Create the delivery channel to send Config data to S3 and SNS
resource "aws_config_delivery_channel" "config" {
  count          = local.should_create_delivery_channel ? 0 : 1
  name           = "${var.resource_prefix}-config-delivery" # Custom name for delivery channel
  s3_bucket_name = var.s3_bucket_id                         # Destination S3 bucket
  s3_key_prefix  = var.s3_key_prefix
  s3_kms_key_arn = var.s3_kms_key_arn
  sns_topic_arn  = var.create_sns_topic ? aws_sns_topic.config_delivery[0].arn : null # SNS topic for notifications

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency # How often snapshots are delivered (e.g., 6 hours)
  }

  depends_on = [aws_config_configuration_recorder.config]
}

# Create SNS Topic for AWS Config notifications
resource "aws_sns_topic" "config_delivery" {
  count             = var.create_sns_topic ? 1 : 0        # Conditionally create the SNS topic only if var.create_sns_topic is true
  name              = "${var.resource_prefix}-sns-config" # Custom name for SNS topic
  kms_master_key_id = var.sns_kms_key_id                  # KMS key for encrypting SNS messages
  tags              = var.tags
}

# Enable the configuration recorder
resource "aws_config_configuration_recorder_status" "config" {
  count = var.create_config_recorder ? 1 : 0
  name       = aws_config_configuration_recorder.config[count.index].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config]
}