variable "aws_regions" {
  description = "The AWS region(s) for AWS Config Aggregator"
  type        = list(string)
}

variable "all_regions" {
  description = "AWS Config Aggregator pulls from all AWS Regions"
  type        = bool
  default     = false
}

variable "is_gov" {
  description = "AWS Config deployed in Gov account?"
  type        = bool
}

variable "account_ids" {
  description = "If Aggregating by Account - AWS Account IDs for AWS Config Aggregator"
  type        = list(string)
  default     = [""]
}

variable "resource_prefix" {
  description = "The prefix for the s3 bucket names"
  type        = string
}

variable "is_enabled" {
  description = "Should config recorder be enabled?"
  type        = bool
  default     = true
}

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
    condition = contains(
      ["account", "organization", "none"],
      var.aggregation_type
    )
    error_message = "Valid values are: account, organization, or none."
  }
}
