## GLOBAL / ENVIRONMENT VARIABLES ##

variable "default_aws_region" {
  description = "The default AWS region to create resources in"
  type        = string
  default     = false
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "is_org" {
  description = "Set to true if deploying AWS Config using AWS Organizations with a delegated administrator. When true, organization-level resources such as organization conformance packs and aggregators will be created. Set to false for standalone (non-org) account deployments."
  type        = bool
  default     = true
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
}

variable "resource_prefix" {
  description = "The prefix for the s3 bucket names"
  type        = string
}

## CONFORMANCE PACK CONFIGURATION VARIABLES ##

variable "pack_names" {
  description = "A list of conformance pack names to be deployed"
  type        = list(string)
}

variable "packs_s3_key" {
  description = "S3 Bucket prefix for the Packs uploaded"
  type        = string
  default     = "packs"
}

## S3 BUCKET VARIABLES ## 

variable "create_s3_config_bucket" {
  description = "Create S3 AWS Config Bucket for conformance pack storage"
  type        = bool
  default     = true
}

variable "s3_bucket_id" {
  description = "Name of the S3 bucket for AWS Config delivery channel"
  type        = string
}

variable "s3_accesslog_bucket_name" {
  description = "The name of the S3 bucket for access logs"
  type        = string
}

variable "s3_backup_settings" {
  description = "Map of S3 bucket types to their backup settings"
  type = map(object({
    enable_backup = bool
  }))
  default = {
    accesslogs = {
      enable_backup = false # Assuming that a SIEM will ingest and store these logs
    }
    elb-accesslogs = {
      enable_backup = false # Assuming that a SIEM will ingest and store these logs
    }
    backups = {
      enable_backup = true
    }
    installs = {
      enable_backup = true
    }
    fedrampdoc = {
      enable_backup = true
    }
    cloudtrail = {
      enable_backup = false # Assuming that a SIEM will ingest and store these logs
    }
    config = {
      enable_backup = true
    }
  }
}

variable "s3_backup_policy" {
  description = "S3 backup policy to use for S3 buckets in conjunction with AWS Backups, should match an existing policy"
  type        = string
  default     = "" # What you specified in AWS Backups pak, may look like "aws-backup-${var.resource_prefix}-default-policy"
}

variable "s3_tags" {
  description = "Tags to be applied to S3 buckets"
  type        = map(any)
  default     = {}
}

## KMS VARIABLES ##

variable "kms_key_id" {
  description = "KMS key for S3"
  type        = string
}