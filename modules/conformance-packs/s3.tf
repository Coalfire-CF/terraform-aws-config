# Original s3-objects
resource "aws_s3_object" "fedramp" {
  bucket = var.s3_bucket_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-FedRAMP.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-FedRAMP.yaml"
}

resource "aws_s3_object" "nist" {
  bucket = var.s3_bucket_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
}

# Conformance Pack S3 Bucket - need to create a new bucket with prefix "awsconfigconforms"

module "s3_config_conformance_pack" {
  count = var.create_s3_config_bucket ? 1 : 0

  source = "github.com/Coalfire-CF/terraform-aws-s3?ref=v1.0.4"

  name                    = "awsconfigconforms-${var.resource_prefix}-${var.aws_region}"
  kms_master_key_id       = var.kms_key_id
  attach_public_policy    = false
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # S3 Access Logs
  logging       = true
  target_bucket = var.s3_accesslog_bucket_name
  target_prefix = "config/"

  # Tags
  tags = merge(
    try(var.s3_backup_settings["config"].enable_backup, false) && length(var.s3_backup_policy) > 0 ? {
      backup_policy = var.s3_backup_policy
    } : {},
    var.s3_tags
  )
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  count  = var.create_s3_config_bucket && var.default_aws_region == var.aws_region ? 1 : 0
  bucket = module.s3_config_conformance_pack[0].id

  policy = data.aws_iam_policy_document.s3_config_bucket_policy_doc[0].json
}

data "aws_iam_policy_document" "s3_config_bucket_policy_doc" {
  count = var.create_s3_config_bucket && var.default_aws_region == var.aws_region ? 1 : 0

  # https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-policy.html#granting-access-in-another-account

  # Base Permissions
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = [
      module.s3_config_conformance_pack[0].arn
    ]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_number]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${module.s3_config_conformance_pack[0].arn}/*"
    ]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_number]
    }
  }

  # Sharing with AWS Account IDs
  dynamic "statement" {
    for_each = length(var.application_account_numbers) > 0 ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "s3:GetBucketAcl",
        "s3:ListBucket"
      ]
      resources = [
        module.s3_config_conformance_pack[0].arn
      ]
      principals {
        type        = "Service"
        identifiers = ["config.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = var.application_account_numbers
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.application_account_numbers) > 0 ? [1] : []
    content {
      effect  = "Allow"
      actions = ["s3:PutObject"]
      resources = [
        "${module.s3_config_conformance_pack[0].arn}/*"
      ]
      principals {
        type        = "Service"
        identifiers = ["config.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = var.application_account_numbers
      }
    }
  }

  # Sharing with AWS Organization ID
  dynamic "statement" {
    for_each = var.organization_id != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "s3:GetBucketAcl",
        "s3:ListBucket"
      ]
      resources = [
        module.s3_config_conformance_pack[0].arn
      ]
      principals {
        type        = "Service"
        identifiers = ["config.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:PrincipalOrgID"
        values   = [var.organization_id]
      }
    }
  }

  dynamic "statement" {
    for_each = var.organization_id != null ? [1] : []
    content {
      effect  = "Allow"
      actions = ["s3:PutObject"]
      resources = [
        "${module.s3_config_conformance_pack[0].arn}/*"
      ]
      principals {
        type        = "Service"
        identifiers = ["config.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"
        values   = ["bucket-owner-full-control"]
      }
      condition {
        test     = "StringEquals"
        variable = "aws:PrincipalOrgID"
        values   = [var.organization_id]
      }
    }
  }
}