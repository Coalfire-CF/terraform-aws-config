provider "aws" {
  alias  = "org-root"
  region = var.aws_region
  profile = var.profile     # Ensure this is org-root account
}

resource "aws_organizations_organization" "this" {
  provider    = aws.org-root
  feature_set = "ALL"
}

resource "aws_organizations_trusted_service_access" "config" {
  provider          = aws.org-root
  service_principal = "config.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "config_delegate" {
  provider          = aws.org-root
  account_id        = var.org_account_id      # Ensure the mgmt account is assigned as the delegated admin
  service_principal = "config.amazonaws.com"
}