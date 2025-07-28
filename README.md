![Coalfire](coalfire_logo.png)

# terraform-aws-config

## Description

This module creates the necessary resources for AWS Config deployment and configuration.

## Dependencies
- [Account Setup module](https://github.com/Coalfire-CF/terraform-aws-account-setup)

## Resource List
- AWS Config Recorder
- AWS Config Delivery Channel (S3 + SNS)
- AWS IAM policies
- AWS Config Aggregator (Account or Organization)
- Uploads S3 Object(s) to X bucket for the Config Conformance Packs
- Config Conformance Packs x2: [Operational-Best-Practices-for-FedRAMP](https://docs.aws.amazon.com/config/latest/developerguide/operational-best-practices-for-fedramp-moderate.html) and [Operational-Best-Practices-for-NIST-800-53-rev-5](https://docs.aws.amazon.com/config/latest/developerguide/operational-best-practices-for-nist-800-53_rev_5.html) Modified from source [Github](https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs)

## Code Updates
- Please be sure to update AWS Config Rules yaml files from [here](https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs)
- Due to the nature of this Github repository being opensource there are a few rules out of the box that were removed in order to get this module to properly scan the AWS Accounts

## Usage

```hcl
module "config" {
  source = "github.com/Coalfire-CF/terraform-aws-config"

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
  aggregation_type = "organization"
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

2. Create a properly defined main.tf file via the template found under 'Usage' while adjusting auto.tfvars as needed. Note that many provided variables are outputs from other modules. Example parent directory:

   ```hcl
   ├── Example/
   │   ├── example.auto.tfvars   
   │   ├── main.tf
   │   ├── outputs.tf
   │   ├── providers.tf
   │   ├── remote-data.tf
   │   ├── required-providers.tf
   │   ├── variables.tf
   │   ├── ...
   ```
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

3. Initialize the Terraform working directory:
   ```hcl
   terraform init
   ```
   Create an execution plan and verify the resources being created:
   ```hcl
   terraform plan
   ```
   Apply the configuration:
   ```hcl
   terraform apply
   ```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_config_baseline"></a> [config\_baseline](#module\_config\_baseline) | ./modules/config | n/a |
| <a name="module_conformance_packs"></a> [conformance\_packs](#module\_conformance\_packs) | ./modules/conformance-packs | n/a |
| <a name="module_organization_admin"></a> [organization\_admin](#module\_organization\_admin) | ./modules/organization-admin | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_number"></a> [account\_number](#input\_account\_number) | The AWS account number where this Terraform deployment is running. | `string` | n/a | yes |
| <a name="input_aggregation_type"></a> [aggregation\_type](#input\_aggregation\_type) | Aggregation Type | `string` | `"organization"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region for AWS Config Delegated Admin | `string` | n/a | yes |
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | The AWS region(s) for AWS Config Aggregator | `list(string)` | `null` | no |
| <a name="input_config_kms_key_arn"></a> [config\_kms\_key\_arn](#input\_config\_kms\_key\_arn) | AWS Config KMS Key Arn | `string` | `null` | no |
| <a name="input_config_role_arn"></a> [config\_role\_arn](#input\_config\_role\_arn) | Optional ARN of an IAM Role to use for AWS Config. If not provided, the module can create one. | `string` | `null` | no |
| <a name="input_conformance_pack_names"></a> [conformance\_pack\_names](#input\_conformance\_pack\_names) | A list of conformance pack names to be deployed | `list(string)` | <pre>[<br/>  "Operational-Best-Practices-for-FedRAMP",<br/>  "Operational-Best-Practices-for-NIST-800-53-rev-5"<br/>]</pre> | no |
| <a name="input_create_config_in_admin"></a> [create\_config\_in\_admin](#input\_create\_config\_in\_admin) | Determines whether to create AWS Config resources specifically in the delegated admin account. Set to true to enable creation in the delegated admin, false to skip. | `bool` | `true` | no |
| <a name="input_create_config_recorder"></a> [create\_config\_recorder](#input\_create\_config\_recorder) | Whether to create Config Recorder | `bool` | `true` | no |
| <a name="input_create_delivery_channel"></a> [create\_delivery\_channel](#input\_create\_delivery\_channel) | Whether to create Config Delivery Channel | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Whether to create the SNS topic for AWS Config notifications. Set to false if an external topic is used or notifications are not needed. | `bool` | `false` | no |
| <a name="input_default_aws_region"></a> [default\_aws\_region](#input\_default\_aws\_region) | The default AWS region to create resources in | `string` | `null` | no |
| <a name="input_delegated_org_account_id"></a> [delegated\_org\_account\_id](#input\_delegated\_org\_account\_id) | AWS Account ID to designate as Config delegated administrator | `string` | `null` | no |
| <a name="input_delivery_frequency"></a> [delivery\_frequency](#input\_delivery\_frequency) | frequency for the config snapshots to be sent to S3 | `string` | `"TwentyFour_Hours"` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Deployment type: ORGANIZATION or STANDALONE | `string` | `"ORGANIZATION"` | no |
| <a name="input_enable_config"></a> [enable\_config](#input\_enable\_config) | Flag to enable or disable the deployment of AWS Config resources. Set to false to skip creating Config-related infrastructure. | `bool` | `true` | no |
| <a name="input_is_gov"></a> [is\_gov](#input\_is\_gov) | AWS Config deployed in Gov account? | `bool` | `true` | no |
| <a name="input_is_org"></a> [is\_org](#input\_is\_org) | Set to true if deploying AWS Config using AWS Organizations with a delegated administrator. When true, organization-level resources such as organization conformance packs and aggregators will be created. Set to false for standalone (non-org) account deployments. | `bool` | `true` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key for S3 | `string` | `null` | no |
| <a name="input_org_management_account_id"></a> [org\_management\_account\_id](#input\_org\_management\_account\_id) | The AWS account number of the AWS Organization management (root) account. | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | AWS Organization ID to restrict IAM policies or bucket policies | `string` | `null` | no |
| <a name="input_packs_s3_key"></a> [packs\_s3\_key](#input\_packs\_s3\_key) | S3 Bucket prefix for the Packs uploaded | `string` | `"packs"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | The AWS profile aligned with the AWS environment to deploy to | `string` | `null` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | The prefix for resource names | `string` | n/a | yes |
| <a name="input_role"></a> [role](#input\_role) | Role of this account: ORG\_MANAGEMENT, DELEGATED\_ADMIN, or MEMBER | `string` | `"MEMBER"` | no |
| <a name="input_s3_accesslog_bucket_name"></a> [s3\_accesslog\_bucket\_name](#input\_s3\_accesslog\_bucket\_name) | S3 Access Log Bucket Name | `string` | `null` | no |
| <a name="input_s3_config_arn"></a> [s3\_config\_arn](#input\_s3\_config\_arn) | S3 Bucket ARN for AWS Config | `string` | `null` | no |
| <a name="input_s3_config_id"></a> [s3\_config\_id](#input\_s3\_config\_id) | S3 bucket ID for AWS Config | `string` | `null` | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | Prefix within the S3 bucket for AWS Config to write data | `string` | `"config"` | no |
| <a name="input_s3_kms_key_arn"></a> [s3\_kms\_key\_arn](#input\_s3\_kms\_key\_arn) | AWS S3 KMS Key Arn | `string` | `null` | no |
| <a name="input_sns_kms_key_id"></a> [sns\_kms\_key\_id](#input\_sns\_kms\_key\_id) | SNS KMS key ID | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_delivery_bucket"></a> [config\_delivery\_bucket](#output\_config\_delivery\_bucket) | S3 bucket used for AWS Config snapshot delivery |
| <a name="output_config_recorder_name"></a> [config\_recorder\_name](#output\_config\_recorder\_name) | Name of the AWS Config configuration recorder |
| <a name="output_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#output\_delegated\_admin\_account\_id) | AWS Account ID designated as delegated admin for AWS Config |
| <a name="output_delegation_delay_id"></a> [delegation\_delay\_id](#output\_delegation\_delay\_id) | Delegation delay resource ID |
| <a name="output_delivery_channel_name"></a> [delivery\_channel\_name](#output\_delivery\_channel\_name) | Name of the AWS Config delivery channel |
| <a name="output_org_conformance_pack_names"></a> [org\_conformance\_pack\_names](#output\_org\_conformance\_pack\_names) | Names of organization-level conformance packs deployed |
| <a name="output_standalone_conformance_pack_names"></a> [standalone\_conformance\_pack\_names](#output\_standalone\_conformance\_pack\_names) | Names of standalone conformance packs deployed |
<!-- END_TF_DOCS -->

## Contributing

[Relative or absolute link to contributing.md](CONTRIBUTING.md)


## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)


## Coalfire Pages

[Absolute link to any relevant Coalfire Pages](https://coalfire.com/)

### Copyright

Copyright © 2023 Coalfire Systems Inc.