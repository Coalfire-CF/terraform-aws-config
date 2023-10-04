resource "aws_config_configuration_recorder" "mgmt_config_recorder" {
  name = "${var.resource_prefix}-config-recorder"

  role_arn = aws_iam_role.r.arn

  dynamic "recording_group" {
    for_each = var.recording_groups
    content {
      all_supported                 = recording_group.value["all_supported"]
      include_global_resource_types = recording_group.value["include_global_resource_types"]
    }
  }

}

resource "aws_config_delivery_channel" "mgmt_s3_delivery_channel" {
  name           = "${var.resource_prefix}-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config.bucket
  depends_on     = [aws_config_configuration_recorder.mgmt_config_recorder]
  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }
}

resource "aws_config_configuration_recorder_status" "aws_config_recorder_status" {
  name       = aws_config_configuration_recorder.mgmt_config_recorder.name
  is_enabled = var.is_enabled
  depends_on = [
    aws_config_delivery_channel.mgmt_s3_delivery_channel
  ]
}
