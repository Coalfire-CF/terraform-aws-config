## GLOBAL / ENVIRONMENT VARIABLES ##

variable "default_aws_region" {
  description = "The default AWS region to create resources in"
  type        = string
}

variable "aws_regions" {
  description = "The AWS region(s) for AWS Config Aggregator"
  type        = list(string)
}

variable "all_regions" {
  description = "AWS Config Aggregator pulls from all AWS Regions"
  type        = bool
  default     = false
}

variable "resource_prefix" {
  description = "The prefix for the s3 bucket names"
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

variable "account_number" {
  description = "The AWS account number resources are being deployed into"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "role_arn" {
  description = "The ARN of the IAM role to be assumed by AWS Config for recording configuration changes or aggregation."
  type        = string
  default     = null
}

## AGGREGATOR CONFIGURATION ## 

variable "account_ids" {
  description = "If Aggregating by Account - AWS Account IDs for AWS Config Aggregator"
  type        = list(string)
  default     = [""]
}

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

variable "organization_id" {
  description = "AWS Organization ID to restrict IAM policies or bucket policies"
  type        = string
  default     = null
}

## S3 BUCKET VARIABLES ## 

variable "s3_bucket_id" {
  description = "Name of the S3 bucket for AWS Config delivery channel"
  type        = string
  default     = null
}

variable "s3_config_arn" {
  description = "S3 Bucket ARN for AWS Config"
  type        = string
  default     = null
}

variable "s3_key_prefix" {
  description = "Prefix within the S3 bucket for AWS Config to write data"
  type        = string
  default     = null
}

## KMS CONFIGURATION ## 

variable "sns_kms_key_id" {
  description = "SNS KMS key ID"
  type        = string
  default     = null
}

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

## CONFIGURATION PARAMETERS ##

variable "create_config_in_admin" {
  description = "Whether to create the AWS Config recorder + delivery channel in the delegated admin account"
  type        = bool
  default     = false
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

variable "delivery_frequency" {
  description = "Frequency for the config snapshots to be sent to S3"
  type        = string

  validation {
    condition = contains([
      "One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"
    ], var.delivery_frequency)
    error_message = "Valid values for delivery_frequency are: One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours."
  }
}

variable "create_sns_topic" {
  description = "Whether to create the SNS topic for AWS Config notifications. Set to false if an external topic is used or notifications are not needed."
  type        = bool
  default     = false
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

variable "deployment_type" {
  description = "Deployment type: ORGANIZATION or STANDALONE"
  type        = string
  default     = "ORGANIZATION"

  validation {
    condition     = contains(["ORGANIZATION", "STANDALONE"], var.deployment_type)
    error_message = "deployment_type must be either ORGANIZATION or STANDALONE"
  }
}