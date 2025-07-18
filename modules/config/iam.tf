# IAM policy document that allows AWS Config to assume this role
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

# IAM policy document that grants full S3 access to specified bucket(s)
data "aws_iam_policy_document" "s3_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      var.s3_config_arn,       # Bucket ARN
      "${var.s3_config_arn}/*" # Objects within the bucket
    ]
  }
}

# IAM policy document that grants full KMS access to Config and S3 keys
data "aws_iam_policy_document" "kms_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
    resources = [
      var.config_kms_key_arn,        # AWS Config KMS key ARN
      "${var.config_kms_key_arn}/*", # Nested resources (if applicable)
      var.s3_kms_key_arn,            # S3 bucket KMS key ARN
      "${var.s3_kms_key_arn}/*"      # Nested resources (if applicable)
    ]
  }
}

# IAM Role that AWS Config assumes
resource "aws_iam_role" "custom_aws_config_role" {
  name               = "AWSConfigCustomRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json # Trust policy
}

# Inline policy attached to the role: grants S3 access
resource "aws_iam_role_policy" "s3_config_role_policy" {
  name   = "AWSConfigS3RolePolicy"
  role   = aws_iam_role.custom_aws_config_role.id
  policy = data.aws_iam_policy_document.s3_role_policy.json
}

# Inline policy attached to the role: grants KMS access
resource "aws_iam_role_policy" "kms_config_role_policy" {
  name   = "AWSConfigKMSRolePolicy"
  role   = aws_iam_role.custom_aws_config_role.id
  policy = data.aws_iam_policy_document.kms_role_policy.json
}

# Attach AWS-managed policy for Config to the role
resource "aws_iam_role_policy_attachment" "config_role_attachment1" {
  role       = aws_iam_role.custom_aws_config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Conditional attachment of the same policy in GovCloud (might be a placeholder)
resource "aws_iam_role_policy_attachment" "config_role_attachment2" {
  count      = var.is_gov ? 1 : 0
  role       = aws_iam_role.custom_aws_config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Duplicate attachment for GovCloud (possibly intended to be a different policy)
resource "aws_iam_role_policy_attachment" "config_role_attachment3" {
  count      = var.is_gov ? 1 : 0
  role       = aws_iam_role.custom_aws_config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Attach Org-level Config policy in commercial partitions
resource "aws_iam_role_policy_attachment" "config_role_attachment4" {
  count      = var.is_gov ? 0 : 1
  role       = aws_iam_role.custom_aws_config_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}