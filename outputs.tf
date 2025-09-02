output "fedramp_conformance_pack_arn" {
  value = try(aws_config_conformance_pack.conformance_packs[0].arn, null)
}

output "nist_conformance_pack_arn" {
  value = try(aws_config_conformance_pack.conformance_packs[1].arn, null)
}

output "config_role_arn" {
  description = "ARN of the AWS Config IAM role"
  value       = var.create_iam_role ? aws_iam_role.custom_aws_config_role[0].arn : var.existing_config_role_arn
}
