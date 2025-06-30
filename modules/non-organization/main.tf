provider "aws" {
  region  = "us-gov-west-1"
  profile = "standalone-account"
}

resource "aws_iam_role" "config" {
  name = "AWSConfigRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_attach" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_config_configuration_recorder" "default" {
  name     = "default"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "default" {
  name           = "default"
  s3_bucket_name = var.config_bucket_name
  depends_on     = [aws_config_configuration_recorder.default]
}

resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.default.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.default]
}

# Optional self-aggregator
resource "aws_config_configuration_aggregator" "self" {
  name = "self-account-aggregator"

  account_aggregation_source {
    account_ids     = [data.aws_caller_identity.current.account_id]
    all_regions     = true
  }

  depends_on = [aws_iam_role_policy_attachment.config_attach]
}

data "aws_caller_identity" "current" {}
