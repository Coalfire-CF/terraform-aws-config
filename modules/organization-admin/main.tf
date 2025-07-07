# Handles AWS Config organization admin delegation

# Enable trusted access for AWS Config in the org
resource "aws_organizations_trusted_service_access" "config" {
  service_principal = "config.amazonaws.com"
}

# Designate the delegated administrator account for AWS Config
resource "aws_organizations_delegated_administrator" "config_delegate" {
  account_id        = var.org_account_id
  service_principal = "config.amazonaws.com"
}

# Add a delay to ensure delegation is fully propagated
resource "time_sleep" "delegation_delay" {
  depends_on = [aws_organizations_delegated_administrator.config_delegate]

  create_duration = "30s"
}