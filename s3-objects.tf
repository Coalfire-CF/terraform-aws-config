resource "aws_s3_object" "fedramp" {
  bucket = var.s3_config_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-FedRAMP.yaml"               # Replace with your desired path and filename
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-FedRAMP.yaml" # Replace with the local path to your YAML file
}

resource "aws_s3_object" "nist" {
  bucket = var.s3_config_id
  key    = "/${var.packs_s3_key}/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml"               # Replace with your desired path and filename
  source = "${path.module}/s3-aws-config-files/Operational-Best-Practices-for-NIST-800-53-rev-5.yaml" # Replace with the local path to your YAML file
}
