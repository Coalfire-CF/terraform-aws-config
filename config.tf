resource "aws_config_configuration_recorder" "config" {
  name     = "${var.resource_prefix}-config"
  role_arn = aws_iam_role.custom_aws_config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }

}

resource "aws_sns_topic" "config_delivery" {
  name              = "${var.resource_prefix}-sns-config"
  kms_master_key_id = var.sns_kms_key_id
}


resource "aws_config_delivery_channel" "config" {
  name           = "${var.resource_prefix}-config-delivery"
  s3_bucket_name = var.s3_config_id
  sns_topic_arn  = aws_sns_topic.config_delivery.arn

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
  count = length(var.conformance_pack_names)

  name               = var.conformance_pack_names[count.index]
  delivery_s3_bucket = var.s3_config_id
  template_s3_uri    = "s3://${var.s3_config_id}/${var.packs_s3_key}/${var.conformance_pack_names[count.index]}.yaml"

  depends_on = [aws_s3_object.fedramp, aws_s3_object.nist]
}


# output "conformance_pack_names" {
#   value = [for pack in aws_config_conformance_pack.pack : pack.name]
# }


# resource "aws_config_configuration_recorder" "mgmt_config_recorder" {
#   name = "${var.resource_prefix}-config-recorder"

#   role_arn = aws_iam_role.r.arn

#   dynamic "recording_group" {
#     for_each = var.recording_groups
#     content {
#       all_supported                 = recording_group.value["all_supported"]
#       include_global_resource_types = recording_group.value["include_global_resource_types"]
#     }
#   }

# }

# resource "aws_config_delivery_channel" "mgmt_s3_delivery_channel" {
#   name           = "${var.resource_prefix}-delivery-channel"
#   s3_bucket_name = aws_s3_bucket.config.bucket
#   depends_on     = [aws_config_configuration_recorder.mgmt_config_recorder]
#   snapshot_delivery_properties {
#     delivery_frequency = var.delivery_frequency
#   }
# }

# resource "aws_config_configuration_recorder_status" "aws_config_recorder_status" {
#   name       = aws_config_configuration_recorder.mgmt_config_recorder.name
#   is_enabled = var.is_enabled
#   depends_on = [
#     aws_config_delivery_channel.mgmt_s3_delivery_channel
#   ]
# }
