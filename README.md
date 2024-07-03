![Coalfire](coalfire_logo.png)

# AWS Config Terraform Module

## Dependencies
- (Account Setup module)[]

## Resource List
- AWS Config Recorder
- AWS Config Delivery Channel (S3 + SNS)
- AWS IAM policies
- AWS Config Aggregator (Account or Organization)
- Uploads S3 Object(s) to X bucket for the Config Conformance Packs
- Config Conformance Packs x2 (Operational-Best-Practices-for-FedRAMP and Operational-Best-Practices-for-NIST-800-53-rev-5)

## Code Updates
- Please be sure to update AWS Config Rules yaml files from [here](https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs)

## Deployment Steps

This module can be called as outlined below.

- Change directories to the `config` directory.
- From the `terraform/aws/config` directory run `terraform init`.
- Run `terraform plan` to review the resources being created.
- If everything looks correct in the plan output, run `terraform apply`.

## Usage

Include example for how to call the module below with generic variables

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
}
#this can be called in region setup
module "config" {
  source                    = "github.com/Coalfire-CF/terraform-aws-config"
  kms_s3_arn = var.kms_key_arn
  aws_region = var.aws_region
  resource_prefix = var.resource_prefix
  is_enabled = True
  delivery_frequency = "One_Hour"
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.26 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.26 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.kms_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_description"></a> [key\_description](#input\_key\_description) | The description given to the created CMK | `string` | `""` | no |
| <a name="input_key_policy"></a> [key\_policy](#input\_key\_policy) | IAM key policy for the kms key | `any` | `null` | no |
| <a name="input_kms_key_resource_type"></a> [kms\_key\_resource\_type](#input\_kms\_key\_resource\_type) | the type of resource/service this key is for, such as S3, EBS or RDS | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | The prefix of the KMS key alias | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The arn of the s3 kms key |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The id of the s3 key |
<!-- END_TF_DOCS -->

## Contributing

[Relative or absolute link to contributing.md](CONTRIBUTING.md)


## License

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/license/mit/)


## Coalfire Pages

[Absolute link to any relevant Coalfire Pages](https://coalfire.com/)

### Copyright

Copyright © 2023 Coalfire Systems Inc.
