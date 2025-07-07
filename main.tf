# Step 1: Organization Admin Delegation (only in org management account)
module "organization_admin" {
  count  = local.is_org_management_account && var.delegated_org_account_id  != null ? 1 : 0
  source = "./modules/organization-admin"

  org_account_id  = var.delegated_org_account_id
  aws_region      = var.aws_region
  profile         = var.profile

}


##add tags