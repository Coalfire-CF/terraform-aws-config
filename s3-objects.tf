### Config Standalone Objects ###
resource "aws_s3_object" "fedramp" {
  count  = (var.upload_conformance_objects && !var.is_org) ? 1 : 0
  bucket = var.s3_config_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-FedRAMP.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-FedRAMP.yaml"
}

resource "aws_s3_object" "nist" {
  count  = (var.upload_conformance_objects && !var.is_org) ? 1 : 0
  bucket = var.s3_config_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
}

### Config ORG Objects ###
resource "aws_s3_object" "org_nist" {
  count = var.upload_conformance_objects && var.is_org ? 1 : 0

  bucket = var.s3_config_conform_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
}

resource "aws_s3_object" "org_fedramp" {
  count = var.upload_conformance_objects && var.is_org ? 1 : 0

  bucket = var.s3_config_conform_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-FedRAMP.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-FedRAMP.yaml"
}