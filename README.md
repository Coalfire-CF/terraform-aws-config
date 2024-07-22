# AWS Config Terraform Module

![Coalfire](coalfire_logo.png)

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

## Deployment Steps

This module can be called as outlined below.

- Change directories to the `config` directory.
- From the `terraform/aws/config` directory run `terraform init`.
- Run `terraform plan` to review the resources being created.
- If everything looks correct in the plan output, run `terraform apply`.

## Usage

Include example for how to call the module below with generic variables

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
| [aws_s3_object.fedramp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.nist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_sns_topic.config_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_iam_policy_document.aggregator_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_ids"></a> [account\_ids](#input\_account\_ids) | AWS Account IDs for AWS Config Aggregator | `list(string)` | n/a | yes |
| <a name="input_aggregation_type"></a> [aggregation\_type](#input\_aggregation\_type) | Aggregation Type | `string` | n/a | yes |
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | The AWS region(s) for AWS Config Aggregator | `list(string)` | n/a | yes |
| <a name="input_config_kms_key_arn"></a> [config\_kms\_key\_arn](#input\_config\_kms\_key\_arn) | AWS Config KMS Key Arn | `string` | n/a | yes |
| <a name="input_conformance_pack_names"></a> [conformance\_pack\_names](#input\_conformance\_pack\_names) | A list of conformance pack names to be deployed | `list(string)` | n/a | yes |
| <a name="input_delivery_frequency"></a> [delivery\_frequency](#input\_delivery\_frequency) | frequency for the config snapshots to be sent to S3 | `string` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Should config recorder be enabled? | `bool` | `true` | no |
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
