## GLOBAL ##

variable "aws_region" {
  description = "The AWS region for AWS Config Delegated Admin"
  type        = string
  default     = null
}

variable "aws_regions" {
  description = "The AWS region(s) for AWS Config Aggregator"
  type        = list(string)
  default     = null
}

variable "default_aws_region" {
  description = "The default AWS region to create resources in"
  type        = string
  default     = null
}

variable "is_gov" {
  description = "AWS Config deployed in Gov account?"
  type        = bool
  default     = true
}

variable "is_org" {
  description = "Set to true if deploying AWS Config using AWS Organizations with a delegated administrator. When true, organization-level resources such as organization conformance packs and aggregators will be created. Set to false for standalone (non-org) account deployments."
  type        = bool
  default     = true
}

variable "delegated_org_account_id" {
  description = "AWS Account ID to designate as Config delegated administrator"
  type        = string
  default     = null
}

variable "account_number" {
  description = "The AWS account number resources are being deployed into"
  type        = string
  default     = null
  
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_number))
    error_message = "account_number must be a valid 12-digit AWS account ID"
  }
}

variable "resource_prefix" {
  description = "The prefix for resource names"
  type        = string
  default     = null
}

variable "profile" {
  description = "The AWS profile aligned with the AWS environment to deploy to"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "organization_id" {
  description = "AWS Organization ID to restrict IAM policies or bucket policies"
  type        = string
  default     = null
}

## S3 ##
variable "s3_config_arn" {
  description = "S3 Bucket ARN for AWS Config"
  type        = string
  default     = null
}

variable "s3_config_id" {
  description = "S3 bucket ID for AWS Config"
  type        = string
  default     = null
}

variable "packs_s3_key" {
  description = "S3 Bucket prefix for the Packs uploaded"
  type        = string
  default     = "packs"
}

variable "kms_key_id" {
  description = "KMS key for S3"
  type        = string
  default     = null
}

variable "s3_accesslog_bucket_name" {
  description = "S3 Access Log Bucket Name"
  type        = string
  default     = null
}

variable "s3_key_prefix" {
  description = "Prefix within the S3 bucket for AWS Config to write data"
  type        = string
  default     = "config"
}

## KMS ##
variable "config_kms_key_arn" {
  description = "AWS Config KMS Key Arn"
  type        = string
  default     = null
}

variable "s3_kms_key_arn" {
  description = "AWS S3 KMS Key Arn"
  type        = string
  default     = null
}

variable "sns_kms_key_id" {
  description = "SNS KMS key ID"
  type        = string
  default     = null
}

variable "delivery_frequency" {
  type        = string
  description = "frequency for the config snapshots to be sent to S3"
  default     = "TwentyFour_Hours"

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
  default     = ["Operational-Best-Practices-for-FedRAMP", "Operational-Best-Practices-for-NIST-800-53-rev-5"]
}

## Aggregator Variables ##
variable "aggregation_type" {
  description = "Aggregation Type"
  type        = string
  default     = "organization"
  validation {
    condition = contains([
      "account", "organization"
    ], var.aggregation_type)
    error_message = "Valid values for var: account or organization."
  }
}

# Deployment Configuration
variable "create_config_in_admin" {
  type    = bool
  default = true
}

variable "create_config_recorder" {
  description = "Whether to create Config Recorder (false will use existing detector)"
  type        = bool
  default     = true
}

variable "create_delivery_channel" {
  description = "Whether to create Config Delivery Channel (false will use existing detector)"
  type        = bool
  default     = true
}

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

variable "create_sns_topic" {
  description = "Whether to create the SNS topic for AWS Config notifications. Set to false if an external topic is used or notifications are not needed."
  type        = bool
  default     = false
}