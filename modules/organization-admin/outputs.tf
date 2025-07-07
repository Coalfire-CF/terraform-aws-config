output "delegated_admin_account_id" {
  description = "The AWS Account ID designated as the delegated administrator for AWS Config"
  value       = aws_organizations_delegated_administrator.config_delegate.account_id
}

output "delegation_delay_id" {
  description = "ID of the time_sleep resource used to delay after delegation"
  value       = time_sleep.delegation_delay.id
}