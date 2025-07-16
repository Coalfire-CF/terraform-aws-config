## GLOBAL / ENVIRONMENT VARIABLES ##

variable "aws_regions" {
  description = "The AWS region(s) for AWS Config Aggregator"
  type        = list(string)
}

variable "all_regions" {
  description = "AWS Config Aggregator pulls from all AWS Regions"
  type        = bool
  default     = false
}

# variable "default_aws_region" {
#   description = "The default AWS region to create resources in"
#   type        = string
# }

# variable "account_number" {
#   description = "The AWS account number resources are being deployed into"
#   type        = string
# }

variable "resource_prefix" {
  description = "The prefix for the s3 bucket names"
  type        = string
}

# variable "role_arn" {
#   description = "The ARN of the IAM role that AWS Config uses to record and deliver configuration changes."
#   type        = string
# }

variable "is_gov" {
  description = "AWS Config deployed in Gov account?"
  type        = bool
  default     = true
}

variable "is_org" {
  description = "Set to true if deploying AWS Config using AWS Organizations with a delegated administrator. When true, organization-level resources such as organization conformance packs and aggregators will be created. Set to false for standalone (non-org) account deployments."
  type        = bool
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
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

## S3 BUCKET VARIABLES ## 

variable "s3_bucket_id" {
  description = "Name of the S3 bucket for AWS Config delivery channel"
  type        = string
}

variable "s3_config_arn" {
  description = "S3 Bucket ARN for AWS Config"
  type        = string
}

## KMS CONFIGURATION ## 

variable "sns_kms_key_id" {
  description = "SNS KMS key ID"
  type        = string
}

variable "config_kms_key_arn" {
  description = "AWS Config KMS Key Arn"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "AWS S3 KMS Key Arn"
  type        = string
}

## CONFIGURATION PARAMETERS ##

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