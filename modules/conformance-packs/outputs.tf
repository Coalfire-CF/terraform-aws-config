# Output the names of organization-level conformance packs
output "org_conformance_pack_names" {
  description = "Names of the AWS Config organization-level conformance packs deployed"
  value       = var.is_org ? aws_config_organization_conformance_pack.this[*].name : []
}

# Output the names of standalone conformance packs
output "standalone_conformance_pack_names" {
  description = "Names of the AWS Config standalone conformance packs deployed"
  value       = var.is_org ? [] : aws_config_conformance_pack.this[*].name
}

# Optional: Output all conformance pack ARNs (org or standalone)
output "conformance_pack_arns" {
  description = "ARNs of deployed AWS Config conformance packs"
  value = var.is_org ? aws_config_organization_conformance_pack.this[*].arn : aws_config_conformance_pack.this[*].arn
}