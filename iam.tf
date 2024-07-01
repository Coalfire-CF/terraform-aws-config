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
      "${var.config_kms_key_arn}/*"
    ]
  }
}

resource "aws_iam_role" "custom_aws_config_role" {
  name               = "AWSConfigCustomRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "s3_config_role_policy" {

  name   = "AWSConfigS3RolePolicy"
  role   = aws_iam_role.custom_aws_config_role.id
  policy = data.aws_iam_policy_document.s3_role_policy.json
}

resource "aws_iam_role_policy" "kms_config_role_policy" {

  name   = "AWSConfigKMSRolePolicy"
  role   = aws_iam_role.custom_aws_config_role.id
  policy = data.aws_iam_policy_document.kms_role_policy.json
}

resource "aws_iam_role_policy_attachment" "config_role_attachment" {
  role       = aws_iam_role.custom_aws_config_role.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWS_ConfigRole"
}

# resource "aws_iam_role" "r" {
#   name = "awsconfig-role"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "config.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy" "p" {
#   name = "awsconfig-s3-policy"
#   role = aws_iam_role.r.id

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "s3:*"
#       ],
#       "Effect": "Allow",
#       "Resource": [
#         "${aws_s3_bucket.config.arn}",
#         "${aws_s3_bucket.config.arn}/*"
#       ]
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "a" {
#   role       = aws_iam_role.r.name
#   policy_arn = "arn:aws-us-gov:iam::aws:policy/service-role/AWSConfigRole"
# }
