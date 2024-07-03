output "fedramp_conformance_pack_arn" {
  value = aws_config_conformance_pack.conformance_packs[0].arn
}

output "nist_conformance_pack_arn" {
  value = aws_config_conformance_pack.conformance_packs[1].arn
}
