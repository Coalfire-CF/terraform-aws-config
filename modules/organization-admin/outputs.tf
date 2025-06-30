# modules/organization-admin/outputs.tf

output "delegated_admin_account_id" {
  description = "The AWS account ID of the delegated admin for AWS Config"
  value       = var.org_account_id
}

output "delegation_complete" {
  description = "Resource ID indicating delegation is complete (for dependencies)"
  value       = time_sleep.delegation_delay.id
}

output "delegation_timestamp" {
  description = "When the delegation was created"
  value       = time_sleep.delegation_delay.create_duration
}