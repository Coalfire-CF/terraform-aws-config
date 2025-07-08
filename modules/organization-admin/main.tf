# Handles AWS Config organization admin delegation

# Designate the delegated administrator account for AWS Config
resource "aws_organizations_delegated_administrator" "config_delegate" {
  account_id        = var.org_account_id
  service_principal = "config.amazonaws.com"

  lifecycle {
    create_before_destroy = false
  }
}

# Add a delay to ensure delegation is fully propagated
resource "time_sleep" "delegation_delay" {
  depends_on = [aws_organizations_delegated_administrator.config_delegate]
  create_duration = "30s"
}
