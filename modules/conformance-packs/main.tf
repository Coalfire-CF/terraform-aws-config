# Organization conformance packs (For clients who use AWS Organizations)
resource "aws_config_organization_conformance_pack" "conformance_packs" {
  count              = var.is_org ? length(var.pack_names) : 0
  name               = var.pack_names[count.index]
  delivery_s3_bucket = var.create_s3_config_bucket ? module.s3_config_conformance_pack[0].id : var.s3_bucket_id
  template_s3_uri    = var.create_s3_config_bucket ? "s3://${module.s3_config_conformance_pack[0].id}/${var.packs_s3_key}/${var.pack_names[count.index]}.yaml" : "s3://${var.s3_bucket_id}/${var.packs_s3_key}/${var.pack_names[count.index]}.yaml"
  depends_on         = [aws_s3_object.fedramp, aws_s3_object.nist]
}

# Standalone conformance packs (For clients who DO NOT use AWS Organizations)
resource "aws_config_conformance_pack" "conformance_packs" {
  count              = var.is_org ? 0 : length(var.pack_names)
  name               = var.pack_names[count.index]
  delivery_s3_bucket = var.create_s3_config_bucket ? module.s3_config_conformance_pack[0].id : var.s3_bucket_id
  template_s3_uri    = var.create_s3_config_bucket ? "s3://${module.s3_config_conformance_pack[0].id}/${var.packs_s3_key}/${var.pack_names[count.index]}.yaml" : "s3://${var.s3_bucket_id}/${var.packs_s3_key}/${var.pack_names[count.index]}.yaml"
  depends_on         = [aws_s3_object.fedramp, aws_s3_object.nist]
}




