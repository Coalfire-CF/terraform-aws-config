data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "s3_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      var.s3_config_arn,
      "${var.s3_config_arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "kms_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
    resources = [
      var.config_kms_key_arn,
      "${var.config_kms_key_arn}/*",
      var.s3_kms_key_arn,
      "${var.s3_kms_key_arn}/*"
    ]
  }
}

resource "aws_iam_role" "custom_aws_config_role" {
  name               = "AWSConfigCustomRole-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "s3_config_role_policy" {
  name   = "AWSConfigS3RolePolicy-${data.aws_region.current.name}"
  role   = aws_iam_role.custom_aws_config_role.id
  policy = data.aws_iam_policy_document.s3_role_policy.json
}

resource "aws_iam_role_policy" "kms_config_role_policy" {
  name   = "AWSConfigKMSRolePolicy-${data.aws_region.current.name}"
  role   = aws_iam_role.custom_aws_config_role.id
  policy = data.aws_iam_policy_document.kms_role_policy.json
}

resource "aws_iam_role_policy_attachment" "config_role_attachment1" {
  role       = aws_iam_role.custom_aws_config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy_attachment" "config_role_attachment2" {
  count = var.is_gov ? 1 : 0

  role       = aws_iam_role.custom_aws_config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy_attachment" "config_role_attachment4" {
  count = var.is_gov ? 1 : 0

  role       = aws_iam_role.custom_aws_config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

