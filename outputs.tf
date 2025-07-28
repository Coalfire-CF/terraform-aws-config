# Outputs from organization_admin module (delegated admin)
output "delegated_admin_account_id" {
  description = "AWS Account ID designated as delegated admin for AWS Config"
  value       = try(module.organization_admin[0].delegated_admin_account_id, null)
}

output "delegation_delay_id" {
  description = "Delegation delay resource ID"
  value       = try(module.organization_admin[0].delegation_delay_id, null)
}

# Outputs from config_baseline module (Config recorder and delivery)
output "config_recorder_name" {
  description = "Name of the AWS Config configuration recorder"
  value       = module.config_baseline[0].config_recorder_name
}

output "delivery_channel_name" {
  description = "Name of the AWS Config delivery channel"
  value       = module.config_baseline[0].delivery_channel_name
}

output "config_delivery_bucket" {
  description = "S3 bucket used for AWS Config snapshot delivery"
  value       = module.config_baseline[0].config_delivery_bucket
}

# Outputs from conformance_packs module
output "org_conformance_pack_names" {
  description = "Names of organization-level conformance packs deployed"
  value       = module.conformance_packs.org_conformance_pack_names
}

output "standalone_conformance_pack_names" {
  description = "Names of standalone conformance packs deployed"
  value       = module.conformance_packs.standalone_conformance_pack_names
}