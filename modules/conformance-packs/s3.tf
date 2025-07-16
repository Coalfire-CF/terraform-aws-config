# Upload conformance pack YAML for FedRAMP to S3
resource "aws_s3_object" "fedramp" {
  bucket = var.s3_bucket_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-FedRAMP.yaml"                # Object key (path) in bucket
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-FedRAMP.yaml"  # Local file source
}

# Upload conformance pack YAML for NIST 800-53 to S3
resource "aws_s3_object" "nist" {
  bucket = var.s3_bucket_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
}

# Optional: Create dedicated S3 bucket for AWS Config conformance packs
module "s3_config_conformance_pack" {
  count = var.create_s3_config_bucket ? 1 : 0  # Only create if explicitly enabled

  source = "github.com/Coalfire-CF/terraform-aws-s3?ref=v1.0.4"

  name                    = "awsconfigconforms-${var.resource_prefix}-${var.aws_region}"  # Bucket name with prefix
  kms_master_key_id       = var.kms_key_id
  attach_public_policy    = false                                                         # Deny public access
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # S3 access logging
  logging       = true
  target_bucket = var.s3_accesslog_bucket_name         # Where access logs should be delivered
  target_prefix = "config/"                            # Prefix for logs in logging bucket

  # Merge backup tags with general tags
  tags = merge(
    try(var.s3_backup_settings["config"].enable_backup, false) && length(var.s3_backup_policy) > 0 ? {
      backup_policy = var.s3_backup_policy
    } : {},
    var.s3_tags
  )
}

# Attach a policy to the config conformance pack bucket
resource "aws_s3_bucket_policy" "config_bucket_policy" {
  count  = var.create_s3_config_bucket && var.default_aws_region == var.aws_region ? 1 : 0
  bucket = module.s3_config_conformance_pack[0].id

  policy = data.aws_iam_policy_document.s3_config_bucket_policy_doc[0].json
}

# Build the S3 bucket policy document to allow AWS Config service access
data "aws_iam_policy_document" "s3_config_bucket_policy_doc" {
  count = var.create_s3_config_bucket && var.default_aws_region == var.aws_region ? 1 : 0

  # Official AWS guidance: https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-policy.html#granting-access-in-another-account

  # Base permissions for AWS Config (Get/ACL/List)
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
      identifiers = ["config.amazonaws.com"]  # AWS Config service principal
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_number]  # Enforce source account restriction
    }
  }

  # Allow Config to PUT objects into the bucket
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
      values   = ["bucket-owner-full-control"]  # Ensure object ownership
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_number]
    }
  }

  # Optional: Share bucket access with other AWS accounts (e.g., delegated Config accounts)
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
        values   = var.application_account_numbers  # Accept list of allowed account IDs
      }
    }
  }

  # Allow PUT access for shared accounts
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

  # Optional: Share with all accounts in the same AWS Organization
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

  # Allow PUT access for Config service within the organization
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