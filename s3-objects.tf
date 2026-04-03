resource "aws_s3_object" "config_packs" {
  for_each = local.all_pack_names

  bucket = var.s3_config_id
  key    = "/${var.packs_s3_key}/${each.key}.yaml"
  source = "${path.module}/s3-aws-config-files/${each.key}.yaml"
  etag   = filemd5("${path.module}/s3-aws-config-files/${each.key}.yaml")
}