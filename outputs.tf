# output "fedramp_conformance_pack_arn" {
#   value = try(aws_config_conformance_pack.conformance_packs[0].arn, null)
# }

# output "nist_conformance_pack_arn" {
#   value = try(aws_config_conformance_pack.conformance_packs[1].arn, null)
# }

output "fedramp_conformance_pack_arn" {
  value = try(aws_config_organization_conformance_pack.conformance_packs[0].arn, null)
}

output "nist_conformance_pack_arn" {
  value = try(aws_config_organization_conformance_pack.conformance_packs[1].arn, null)
}