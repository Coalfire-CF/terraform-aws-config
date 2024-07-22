resource "aws_s3_object" "fedramp" {
  bucket = var.s3_config_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-FedRAMP.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-FedRAMP.yaml"
}

resource "aws_s3_object" "nist" {
  bucket = var.s3_config_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"
}
