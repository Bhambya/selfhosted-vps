module gateway {
  source = "./gateway"

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  tenancy_ocid = data.bitwarden_secret.tenancy_ocid.value
  subnet_id = oci_core_subnet.export_subnet-20250216-1019.id
  region = var.region
  ssh_public_key_path = var.ssh_public_key_path
  boot_volume_size = "150"
}

module little_gateway {
  source = "./little-gateway"

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  tenancy_ocid = data.bitwarden_secret.tenancy_ocid.value
  subnet_id = oci_core_subnet.export_subnet-20250216-1019.id
  region = var.region
  ssh_public_key_path = var.ssh_public_key_path
  boot_volume_size = "50"
}
