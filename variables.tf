## GLOBAL ##

variable "aws_region" {
  description = "The AWS region for AWS Config Delegated Admin"
  type        = string
}

variable "aws_regions" {
  description = "The AWS region(s) for AWS Config Aggregator"
  type        = list(string)
}

variable "default_aws_region" {
  description = "The default AWS region to create resources in"
  type        = string
}

variable "is_gov" {
  description = "AWS Config deployed in Gov account?"
  type        = bool
}

variable "is_org" {
  description = "Set to true if deploying AWS Config using AWS Organizations with a delegated administrator. When true, organization-level resources such as organization conformance packs and aggregators will be created. Set to false for standalone (non-org) account deployments."
  type        = bool
}

variable "delegated_org_account_id" {
  description = "AWS Account ID to designate as Config delegated administrator"
  type        = string
  default     = null
}

variable "account_number" {
  description = "The AWS account number resources are being deployed into"
  type        = string
}

variable "resource_prefix" {
  description = "The prefix for the s3 bucket names"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "profile" {
  description = "The AWS profile aligned with the AWS environment to deploy to"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

## S3 ##
variable "s3_config_arn" {
  description = "S3 Bucket ARN for AWS Config"
  type        = string
}

variable "s3_config_id" {
  description = "S3 bucket ID for AWS Config"
  type        = string
}

variable "packs_s3_key" {
  description = "S3 Bucket prefix for the Packs uploaded"
  type        = string
  default     = "packs"
}

variable "kms_key_id" {
  description = "KMS key for S3"
  type        = string
}

variable "s3_accesslog_bucket_name" {
  description = "S3 Access Log Bucket Name"
  type        = string
}

## KMS ##
variable "config_kms_key_arn" {
  description = "AWS Config KMS Key Arn"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "AWS S3 KMS Key Arn"
  type        = string
}

variable "sns_kms_key_id" {
  description = "SNS KMS key ID"
  type        = string
}

variable "delivery_frequency" {
  type        = string
  description = "frequency for the config snapshots to be sent to S3"

  validation {
    condition = contains([
      "One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"
    ], var.delivery_frequency)
    error_message = "Valid values for var: test_variable are (One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours)."
  }
}

variable "conformance_pack_names" {
  description = "A list of conformance pack names to be deployed"
  type        = list(string)
}

## Aggregator Variables ##
variable "aggregation_type" {
  description = "Aggregation Type"
  type        = string
  validation {
    condition = contains([
      "account", "organization"
    ], var.aggregation_type)
    error_message = "Valid values for var: account or organization."
  }
}

# Deployment Configuration
variable "deployment_type" {
  description = "Deployment type: ORGANIZATION or STANDALONE"
  type        = string
  default     = "ORGANIZATION"

  validation {
    condition     = contains(["ORGANIZATION", "STANDALONE"], var.deployment_type)
    error_message = "deployment_type must be either ORGANIZATION or STANDALONE"
  }
}

variable "role" {
  description = "Role of this account: ORG_MANAGEMENT, DELEGATED_ADMIN, or MEMBER"
  type        = string
  default     = "MEMBER"

  validation {
    condition     = contains(["ORG_MANAGEMENT", "DELEGATED_ADMIN", "MEMBER"], var.role)
    error_message = "role must be ORG_MANAGEMENT, DELEGATED_ADMIN, or MEMBER"
  }
}