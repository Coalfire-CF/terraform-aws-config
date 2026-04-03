variable "resource_prefix" {
  description = "A prefix that should be attached to the names of resources"
  type        = string
}

variable "is_gov" {
  description = "Whether or not the environment is being deployed in GovCloud"
  type        = bool
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