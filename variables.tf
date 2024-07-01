# variable "kms_s3_arn" {
#   description = "KMS arn for S3"
#   type        = string
# }

# variable "aws_region" {
#   description = "The AWS region to create things in"
#   type        = string
# }

# variable "default_aws_region" {
#   description = "The default AWS region to create resources in"
#   type        = string
# }


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
  default     = "/packs"
}

variable "config_kms_key_arn" {
  description = "AWS Config KMS Key Arn"
  type        = string
}

variable "s3_kms_key_arn" {
  description = "AWS S3 KMS Key Arn"
  type        = string
}

# variable "recording_groups" {
#   description = "whether AWS Config records configuration changes for every supported type of regional resource or Specifies whether AWS Config includes all supported types of global resources with the resources that it records."
#   default     = []
#   type = list(object({
#     all_supported                 = bool
#     include_global_resource_types = bool
#     resource_types                = optional(list(string))
#   }))
# }

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

# variable "conformance_packs" {
#   description = "A list of conformance packs to create"
#   type = list(object({
#     name          = string
#     template_path = string
#   }))
# }
