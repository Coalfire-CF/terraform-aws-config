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

variable "depends_on" {
  type    = list(any)
  default = []
}