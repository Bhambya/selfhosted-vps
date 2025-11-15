resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init.tftpl",
      {
        hostname : var.hostname,
        ipv4_gateway: var.ipv4_gateway,
        mounts: var.mounts,
        ssh_authorized_keys : var.ssh_authorized_keys,
        additional_rumcmds : var.additional_rumcmds,
        additional_packages : var.additional_packages,
        ufw_allow_rules : var.ufw_allow_rules
      }
    )

    file_name = "${var.hostname}-user-data-cloud-config.yaml"
  }
}
