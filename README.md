![Coalfire](coalfire_logo.png)

# terraform-aws-config

## Description

This module provisions and configures AWS Config to record resource configurations and compliance across an account or organization. It enables configuration recording, delivery channels, and optional organization-wide setup for centralized compliance management.

## Dependencies
- [Account Setup module](https://github.com/Coalfire-CF/terraform-aws-account-setup)
- [OrganizationAccountAccessRole created in delegate-admin account](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_accounts_create-cross-account-role.html)

  In order for you to deploy config to the non-delegate admin accounts, they will need to be able to access the state bucket in the delegate-admin account:
  ```hcl
  data "terraform_remote_state" "fedramp_mgmt_account_setup" {
  backend   = "s3"
  workspace = "default"

  config = {
    bucket  = "${var.resource_prefix}-${var.aws_region}-tf-state"
    region  = var.aws_region
    key     = "${var.resource_prefix}/${var.aws_region}/account-setup.tfstate"

    assume_role = {
      role_arn     = "arn:aws-us-gov:iam::${local.mgmt_plane_account_id}:role/OrganizationAccountAccessRole"
      session_name = "tf-state-access"
    }
  }
}
```

The following modules should already have been applied and configured prior to the deployment steps:

- [Account Setup Module](https://github.com/Coalfire-CF/terraform-aws-account-setup)
- [AWS Organization Module](https://github.com/Coalfire-CF/terraform-aws-organization)

## Resource List
- AWS Config Recorder – Captures configuration changes for supported AWS resources.
- AWS Config Delivery Channel – Delivers configuration snapshots and compliance history to S3 and forwards notifications via SNS.
- AWS IAM policies – Grants Config required permissions for recording and delivery.
- AWS Config Aggregator – Aggregates configuration and compliance data across accounts and regions (single account or organization).
- S3 Object Uploads – Deploys conformance pack templates into the designated S3 bucket for reference.
- Config Conformance Packs – Predefined compliance frameworks:
    - [Operational-Best-Practices-for-FedRAMP-Moderate](https://docs.aws.amazon.com/config/latest/developerguide/operational-best-practices-for-fedramp-moderate.html)
    - [Operational-Best-Practices-for-NIST-800-53-rev-5](https://docs.aws.amazon.com/config/latest/developerguide/operational-best-practices-for-nist-800-53_rev_5.html) 
    - Refer to Coalfire's locally stored Conformance Packs: [Github](https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs)
        - Note: Due to the nature of this Github repository being opensource there are a few rules out of the box that were removed in order to get this module to properly scan the AWS Accounts
        - Please be sure to update AWS Config Rules yaml files from [here](https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs)

## Usage

The following example illustrates a main.tf configuration for clients not using AWS Organizations, showing how AWS Config can be deployed and managed within a single AWS account environment.

```hcl
module "config" {
  source = "github.com/Coalfire-CF/terraform-aws-config?ref=vX.X.X"

  resource_prefix        = var.resource_prefix
  s3_config_arn          = data.terraform_remote_state.mgmt_account_setup.outputs.s3_config_arn
  s3_config_id           = data.terraform_remote_state.mgmt_account_setup.outputs.s3_config_id
  config_kms_key_arn     = data.terraform_remote_state.mgmt_account_setup.outputs.config_kms_key_arn
  s3_kms_key_arn         = data.terraform_remote_state.mgmt_account_setup.outputs.s3_kms_key_arn
  sns_kms_key_id         = data.terraform_remote_state.mgmt_account_setup.outputs.sns_kms_key_id
  conformance_pack_names = ["Operational-Best-Practices-for-FedRAMP", "Operational-Best-Practices-for-NIST-800-53-rev-5"]
  delivery_frequency     = "TwentyFour_Hours"

  ## Aggregator 
  aws_regions      = var.aws_regions
  account_ids      = local.share_accounts
  aggregation_type = "account"
}
```

The following example demonstrates a main.tf configuration for clients using AWS Organizations. One of the key differences in this usage block relates to the delegated administrator and the aggregation type.

A delegated administrator in Config is an AWS account within your organization that is granted the authority to manage Config on behalf of other accounts. This enables centralized management of Config configuration and monitoring.

Use a delegated administrator when:
  - You manage multiple AWS accounts through AWS Organizations.
  - You want a single account (often a management or security account) to handle Config setup and configurations for all member accounts.
  - You want to avoid deploying and maintaining Config in every account individually.

## Management Account: Use this main.tf in the Management Account. Refer to Deployment steps for more guidance. 

```hcl
module "config" {
  source = "github.com/Coalfire-CF/terraform-aws-config?ref=vX.X.X"

  providers = {
    aws = aws.prefix-mgmt
  }

  resource_prefix        = var.resource_prefix
  is_gov                 = var.is_gov
  s3_config_arn          = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_config_arn
  s3_config_id           = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_config_id
  config_kms_key_arn     = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.config_kms_key_arn
  s3_kms_key_arn         = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_kms_key_arn
  sns_kms_key_id         = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.sns_kms_key_id
  conformance_pack_names = ["Operational-Best-Practices-for-FedRAMP", "Operational-Best-Practices-for-NIST-800-53-rev-5"]
  delivery_frequency     = "TwentyFour_Hours"

  ## Aggregator 
  aws_regions      = var.aws_regions
  account_ids      = local.share_accounts
  aggregation_type = "organization"

  depends_on = [aws_organizations_delegated_administrator.config]
}

resource "aws_organizations_delegated_administrator" "config" {  
  provider = aws.prefix-org
  account_id        = local.mgmt_plane_account_id
  service_principal = "config.amazonaws.com"
}
```
## Member Account: Use this main.tf for other in-scope client accounts (if applicable). Refer to Deployment steps for more guidance. 

```hcl
module "config" {
  source = "github.com/Coalfire-CF/terraform-aws-config?ref=vX.X.X"

  providers = {
    aws = aws.prefix-org
  }

  resource_prefix        = var.resource_prefix
  is_gov                 = var.is_gov
  s3_config_arn          = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_config_arn
  s3_config_id           = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_config_id
  config_kms_key_arn     = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.config_kms_key_arn
  s3_kms_key_arn         = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.s3_kms_key_arn
  sns_kms_key_id         = data.terraform_remote_state.fedramp_mgmt_account_setup.outputs.sns_kms_key_id
  delivery_frequency     = "TwentyFour_Hours"

  # Conformance paks are only created in the delegated admin account
  conformance_pack_names = ["Operational-Best-Practices-for-FedRAMP", "Operational-Best-Practices-for-NIST-800-53-rev-5"]
 
  ## Aggregator 
  aws_regions      = var.aws_regions
  account_ids      = local.share_accounts
  aggregation_type = "none"
}

```

## Environment Setup

```hcl
IAM user authentication:

- Download and install the AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Log into the AWS Console and create AWS CLI Credentials (https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- Configure the named profile used for the project, such as 'aws configure --profile example-mgmt'

SSO-based authentication (via IAM Identity Center SSO):

- Login to the AWS IAM Identity Center console, select the permission set for MGMT, and select the 'Access Keys' link.
- Choose the 'IAM Identity Center credentials' method to get the SSO Start URL and SSO Region values.
- Run the setup command 'aws configure sso --profile example-mgmt' and follow the prompts.
- Verify you can run AWS commands successfully, for example 'aws s3 ls --profile example-mgmt'.
- Run 'export AWS_PROFILE=example-mgmt' in your terminal to use the specific profile and avoid having to use '--profile' option.
```

## Deployment

1. Navigate to the Terraform project and create a parent directory in the upper level code, for example:

    ```hcl
    ../{CLOUD}/terraform/{REGION}/management-account/example
    ```

   If multi-account management plane:

    ```hcl
    ../{CLOUD}/terraform/{REGION}/{ACCOUNT_TYPE}-mgmt-account/example
    ```

2. Create a new branch. The branch name should provide a high level overview of what you're working on. 

3. Change directories to the `config` directory. AWS Config needs deployed in each account, thus you must create a `config` directory in each account.

4. Create a properly defined main.tf file via the template found under 'Usage' while adjusting example.auto.tfvars as needed. Note that many provided variables are outputs from other modules. 

IMPORTANT: If a client has a multi-account environment and uses AWS Organizations, ensure that the proper usage block is utilized:
  - The Management Account usage block will contain the delegated admin and aggregator setup. 
  - The Member Account usage block will NOT include the delegated admin setup, conformance packs, or aggregator setup. 

Example parent directory:

   ```hcl
   ├── Example/
   │   ├── example.auto.tfvars
   │   ├── locals.tf  
   │   ├── main.tf
   │   ├── outputs.tf
   │   ├── providers.tf
   │   ├── remote-data.tf
   │   ├── required-providers.tf
   │   ├── variables.tf
   │   ├── ...
   ```
5. Customize code to meet requirements. 

Make sure that 'remote-data.tf' defines the S3 backend which is on the Management account state bucket. For example:

   ```hcl
      terraform {
        backend "s3" {
          bucket       = "${var.resource_prefix}-us-gov-west-1-tf-state"
          region       = "us-gov-west-1"
          key          = "${var.resource_prefix}-us-gov-west-1-aws-config.tfstate"
          encrypt      = true
          use_lockfile = true
        }
      }
   ```

6. If AWS Organizations is in scope. Add AWS Config to the service_access_principals. The below example is from the organization directory's main.tf:
   ```hcl
    service_access_principals = [
      "cloudtrail.amazonaws.com",
      "member.org.stacksets.cloudformation.amazonaws.com",
      "sso.amazonaws.com",
      "ssm.amazonaws.com",
      "servicecatalog.amazonaws.com",
      "guardduty.amazonaws.com",
      "malware-protection.guardduty.amazonaws.com",
      "securityhub.amazonaws.com",
      "ram.amazonaws.com",
      "tagpolicies.tag.amazonaws.com",
      "config.amazonaws.com",  # ENGINEER MUST ADD CONFIG SERVICE
    ]
   ```

7. From the Management Account's `guardduty` directory run, initialize the Terraform working directory. Reminder: the management account will use the Management Account usage block in the main.tf.

   ```hcl
   terraform init
   ```

8. Create an execution plan and verify the resources being created:
   ```hcl
   terraform plan
   ```

9. Apply the configuration:
   ```hcl
   terraform apply
   ```

10. If applicable, repeat Steps 7-9 within each account. This will deploy AWS Config in each account. Reminder: these accounts will use the Member Account usage block in the main.tf.

## Post Deployment Validation
1. Navigate to the AWS Console > Config within each account > Settings. Confirm that Config is enabled. 
2. Navigate to the AWS Console > Config within the Management Account > Conformance Packs. Ensure the desired packs are showing.
3. Navigate to the AWS Console > Config within the Management Account > Aggregators. Ensure you can see multiple accounts under "Accounts by X" dashboard sections.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_config_configuration_aggregator.account_config_aggregator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_aggregator) | resource |
| [aws_config_configuration_aggregator.config_aggregator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_aggregator) | resource |
| [aws_config_configuration_recorder.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_conformance_pack.conformance_packs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_conformance_pack) | resource |
| [aws_config_delivery_channel.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_iam_role.aggregator_organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.custom_aws_config_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.kms_config_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.s3_config_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.aggregator_organization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.config_role_attachment1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.config_role_attachment2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.config_role_attachment3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.config_role_attachment4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_object.fedramp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.nist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_sns_topic.config_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_iam_policy_document.aggregator_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | If Aggregating by Account - AWS Account IDs for AWS Config Aggregator | `list(string)` | <pre>[<br/>  ""<br/>]</pre> | no |
| <a name="input_aggregation_type"></a> [aggregation\_type](#input\_aggregation\_type) | Aggregation Type | `string` | n/a | yes |
| <a name="input_all_regions"></a> [all\_regions](#input\_all\_regions) | AWS Config Aggregator pulls from all AWS Regions | `bool` | `false` | no |
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | The AWS region(s) for AWS Config Aggregator | `list(string)` | n/a | yes |
| <a name="input_config_kms_key_arn"></a> [config\_kms\_key\_arn](#input\_config\_kms\_key\_arn) | AWS Config KMS Key Arn | `string` | n/a | yes |
| <a name="input_conformance_pack_names"></a> [conformance\_pack\_names](#input\_conformance\_pack\_names) | A list of conformance pack names to be deployed | `list(string)` | n/a | yes |
| <a name="input_delivery_frequency"></a> [delivery\_frequency](#input\_delivery\_frequency) | frequency for the config snapshots to be sent to S3 | `string` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Should config recorder be enabled? | `bool` | `true` | no |
| <a name="input_is_gov"></a> [is\_gov](#input\_is\_gov) | AWS Config deployed in Gov account? | `bool` | n/a | yes |
| <a name="input_packs_s3_key"></a> [packs\_s3\_key](#input\_packs\_s3\_key) | S3 Bucket prefix for the Packs uploaded | `string` | `"packs"` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | The prefix for the s3 bucket names | `string` | n/a | yes |
| <a name="input_s3_config_arn"></a> [s3\_config\_arn](#input\_s3\_config\_arn) | S3 Bucket ARN for AWS Config | `string` | n/a | yes |
| <a name="input_s3_config_id"></a> [s3\_config\_id](#input\_s3\_config\_id) | S3 bucket ID for AWS Config | `string` | n/a | yes |
| <a name="input_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#input\_s3\_kms\_key\_arn) | AWS S3 KMS Key Arn | `string` | n/a | yes |
| <a name="input_sns_kms_key_id"></a> [sns\_kms\_key\_id](#input\_sns\_kms\_key\_id) | SNS KMS key ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fedramp_conformance_pack_arn"></a> [fedramp\_conformance\_pack\_arn](#output\_fedramp\_conformance\_pack\_arn) | n/a |
| <a name="output_nist_conformance_pack_arn"></a> [nist\_conformance\_pack\_arn](#output\_nist\_conformance\_pack\_arn) | n/a |
<!-- END_TF_DOCS -->

## Contributing

[Relative or absolute link to contributing.md](CONTRIBUTING.md)


## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)


## Coalfire Pages

[Absolute link to any relevant Coalfire Pages](https://coalfire.com/)

### Copyright

Copyright © 2023 Coalfire Systems Inc.

## Tree
```
.
|-- CHANGELOG.md
|-- CONTRIBUTING.md
|-- LICENSE
|-- README.md
|-- coalfire_logo.png
|-- config-aggregator.tf
|-- config.tf
|-- data.tf
|-- examples
|   |-- organization
|       |-- mgmt_account
|       |   |-- example.auto.tfvars
|       |   |-- locals.tf
|       |   |-- main.tf
|       |   |-- providers.tf
|       |   |-- remote-data.tf
|       |   |-- variables.tf
|       |-- other_accounts
|           |-- example.auto.tfvars
|           |-- locals.tf
|           |-- main.tf
|           |-- providers.tf
|           |-- remote-data.tf
|           |-- variables.tf
|-- iam.tf
|-- outputs.tf
|-- providers.tf
|-- release-please-config.json
|-- s3-aws-config-files
|   |-- Operational-Best-Practices-for-FedRAMP.yaml
|   |-- Operational-Best-Practices-for-NIST-800-53-rev-5.yaml
|-- s3-objects.tf
|-- variables.tf
```
