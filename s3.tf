resource "aws_s3_object" "fedramp" {
  bucket = var.s3_config_id
  key    = "${var.packs_s3_key}/Operational-Best-Practices-for-FedRAMP"                     # Replace with your desired path and filename
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-FedRAMP.yaml" # Replace with the local path to your YAML file
  acl    = "private"

  # tags = {
  #   Terraform = "True"
  # }
}

resource "aws_s3_object" "nist" {
  bucket = var.s3_config_id
  key    = "${var.packs_s3_key}Operational-Best-Practices-for-NIST-800-53-rev-5"                      # Replace with your desired path and filename
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml" # Replace with the local path to your YAML file
  acl    = "private"

  # tags = {
  #   Terraform = "True"
  # }
}



# #############
# resource "aws_s3_bucket" "config" {
#   bucket = var.bucket_name
# }

# # Terraform AWS provider v4.0+ changed S3 bucket config to rely on separate resources instead of in-line config
# resource "aws_s3_bucket_acl" "config_acl" {
#   bucket = aws_s3_bucket.config.id
#   acl    = "log-delivery-write"
# }

# resource "aws_s3_bucket_versioning" "config_versioning" {
#   bucket = aws_s3_bucket.config.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "config_encryption" {
#   bucket = aws_s3_bucket.config.id
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "aws:kms"
#       kms_master_key_id = var.kms_s3_arn
#     }
#   }
# }

# data "aws_iam_policy_document" "config_policy" {
#   statement {
#     actions = ["s3:PutObject", "s3:ListBucket"]
#     effect  = "Allow"
#     principals {
#       identifiers = ["config.amazonaws.com"]
#       type        = "Service"
#     }
#     resources = [
#       "${aws_s3_bucket.config.arn}/*",
#       aws_s3_bucket.config.arn
#     ]
#   }
# }

# resource "aws_s3_bucket_policy" "config_bucket_policy" {
#   bucket = aws_s3_bucket.config.bucket
#   policy = data.aws_iam_policy_document.config_policy.json
# }

# resource "aws_s3_bucket_public_access_block" "config" {
#   bucket = aws_s3_bucket.config.id

#   block_public_acls       = true
#   block_public_policy     = true
#   restrict_public_buckets = true
#   ignore_public_acls      = true
# }
