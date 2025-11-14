resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "proxmox"
  url          = "https://cloud-images.ubuntu.com/noble/20251026/noble-server-cloudimg-amd64.img"
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name          = "noble-server-cloudimg-amd64.qcow2"
  checksum           = "85743244cc8f2f47384480c81dbb677585d20ed693127667dbfb116f1682f793"
  checksum_algorithm = "sha256"
}

locals {
  adugard_host_ip = "192.168.1.107"
  adguard_config = templatefile("${path.module}/adguard_home_config.tftpl",
    {
      base_domain : var.base_domain,
      host_ip : local.adugard_host_ip,
      admin_password_hash : data.bitwarden_secret.adguard_admin_password_hash.value
    }
  )
}

module "adguard" {
  source = "./ubuntu_vm"

  proxmox_node     = "proxmox"
  hostname         = "adguard"
  cpu_cores        = 2
  dedicated_memory = 512
  disk_size        = 4
  disk_import_from = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
  start_order      = 1
  ipv4_address     = "${local.adugard_host_ip}/24"
  ipv4_gateway     = "192.168.1.1"
  ssh_authorized_keys = [
    trimspace(file(var.ssh_public_key_path)),
    trimspace(data.bitwarden_secret.github_ci_ansible_ssh_public_key.value)
  ]
  additional_rumcmds = [
    "curl -fsSL https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v",
    "/opt/AdGuardHome/AdGuardHome -s stop",
    indent(4, "|\ncat > /opt/AdGuardHome/AdGuardHome.yaml <<'EOAC'\n${local.adguard_config}\nEOAC"),
    "/opt/AdGuardHome/AdGuardHome -s start"
  ]
  ufw_allow_rules = [
    "ssh",
    "http",
    "53/tcp",
    "53/udp",
    "51820/udp",
  ]
}
