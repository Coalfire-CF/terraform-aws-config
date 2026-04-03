locals {
  fedramp_pack_files = {
    moderate = ["Operational-Best-Practices-for-FedRAMP-Moderate"]
    high = [
      "Operational-Best-Practices-for-FedRAMP-HighPart1",
      "Operational-Best-Practices-for-FedRAMP-HighPart2"
    ]
  }

  # Final set of all pack names — drives both S3 uploads and conformance pack resources
  all_pack_names = toset(concat(
    local.fedramp_pack_files[var.fedramp_level],
    ["Operational-Best-Practices-for-NIST-800-53-rev-5"],
    var.additional_conformance_packs
  ))
}