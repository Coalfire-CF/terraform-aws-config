variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "profile" {
  description = "The AWS profile aligned with the AWS environment to deploy to"
  type        = string
}

variable "org_account_id" {
  description = "The AWS Account ID of the organization (delegated admin) account"
  type        = string
}
