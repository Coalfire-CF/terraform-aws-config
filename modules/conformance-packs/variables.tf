variable "pack_names" {
  description = "A list of conformance pack names to be deployed"
  type        = list(string)
}

variable "packs_s3_key" {
  description = "S3 Bucket prefix for the Packs uploaded"
  type        = string
  default     = "packs"
}

variable "s3_bucket_id" {
  description = "Name of the S3 bucket for AWS Config delivery channel"
  type        = string
}

variable "is_org" {
  description = "Set to true if deploying AWS Config using AWS Organizations with a delegated administrator. When true, organization-level resources such as organization conformance packs and aggregators will be created. Set to false for standalone (non-org) account deployments."
  type        = bool
}

variable "create_s3_config_bucket" {
  description = "Create S3 AWS Config Bucket for conformance pack storage"
  type        = bool
  default     = true
}

variable "default_aws_region" {
  description = "The default AWS region to create resources in"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "account_number" {
  description = "The AWS account number resources are being deployed into"
  type        = string
}

variable "application_account_numbers" {
  description = "AWS account numbers for all application accounts that might need shared access to resources like KMS keys"
  type        = list(string)
  default     = []
}

variable "organization_id" {
  description = "AWS Organization ID"
  type        = string
  default     = null
}