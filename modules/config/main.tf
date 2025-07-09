# Create SNS Topic for Config
resource "aws_sns_topic" "config_delivery" {
  name              = "${var.resource_prefix}-sns-config"
  kms_master_key_id = var.sns_kms_key_id
  tags = var.tags
}

# Create the config recorder
resource "aws_config_configuration_recorder" "config" {
  name     = "${var.resource_prefix}-config"
  role_arn = aws_iam_role.custom_aws_config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# Delivery channel to S3 + SNS
resource "aws_config_delivery_channel" "config" {
  name           = "${var.resource_prefix}-config-delivery"
  s3_bucket_name = var.s3_bucket_id
  sns_topic_arn  = aws_sns_topic.config_delivery.arn

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.config]
}

# Enable the recorder
resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config]
}
