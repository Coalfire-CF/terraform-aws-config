locals {
  recorder_id = var.create_config_recorder ? aws_config_configuration_recorder.this[0].id : data.aws_config_configuration_recorder.existing[0].id
  delivery_channel_id = var.create_delivery_channel ? aws_config_delivery_channel.this[0].id : data.aws_config_delivery_channel.existing[0].id
}
