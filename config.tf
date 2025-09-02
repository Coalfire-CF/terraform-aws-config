resource "aws_config_configuration_recorder" "config" {
  name     = "${var.resource_prefix}-config"
  role_arn = aws_iam_role.custom_aws_config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

}

resource "aws_sns_topic" "config_delivery" {
  count             = var.aws_region == "us-gov-west-1" ? 1 : 0
  name              = "${var.resource_prefix}-sns-config"
  kms_master_key_id = var.sns_kms_key_id
}

resource "aws_config_delivery_channel" "config" {
  name           = "${var.resource_prefix}-config-delivery-${data.aws_region.current.name}"
  s3_bucket_name = var.s3_config_id
  sns_topic_arn  = length(aws_sns_topic.config_delivery) > 0 ? aws_sns_topic.config_delivery[0].arn : null

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }

}

resource "aws_config_configuration_recorder_status" "config" {
  name       = aws_config_configuration_recorder.config.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.config]
}

resource "aws_config_conformance_pack" "conformance_packs" {
  count = var.create_conformance_packs ? length(var.conformance_pack_names) : 0

  name               = var.conformance_pack_names[count.index]
  delivery_s3_bucket = var.s3_config_id
  template_s3_uri    = "s3://${var.s3_config_id}/${var.packs_s3_key}/${var.conformance_pack_names[count.index]}.yaml"

  depends_on = [aws_s3_object.fedramp, aws_s3_object.nist]
}
