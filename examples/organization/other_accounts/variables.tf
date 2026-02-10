variable "resource_prefix" {
  description = "A prefix that should be attached to the names of resources"
  type        = string
}

variable "is_gov" {
  description = "Whether or not the environment is being deployed in GovCloud"
  type        = bool
}

variable "default_aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-gov-west-1"
}

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "aws_regions" {
  description = "The AWS region to create resources in."
  type        = list(string)
  default     = ["us-gov-west-1", "us-gov-east-1"]
}

variable "upload_conformance_objects" {
  description = "Determines whether or not conformance objects should be created. False if just deploying aws-config to org accounts (not delegated admin account."
  type        = bool
  default     = true
}

variable "create_conformance_packs" {
  description = "Determines whether or not to cerate the conformance paks. False if deploying aws-config to single, non-delegated admin account."
  type        = bool
  default     = true
}

variable "gov_cloud_organization_id" {
  description = "AWS Gov Cloud Organization ID"
  type        = string
}