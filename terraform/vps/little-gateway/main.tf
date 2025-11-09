data "oci_core_images" "ubuntu_image" {
  compartment_id = var.tenancy_ocid

  # Filter for the official "Canonical Ubuntu" image
  operating_system = "Canonical Ubuntu"
  
  operating_system_version = "24.04"

  # THIS IS KEY: Filter for images compatible with the "Always Free" shape
  shape = "VM.Standard.E2.1.Micro"

  # Get the most recent image
  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

resource "oci_core_instance" "little_gateway" {
  # Basic Instance Details
  compartment_id      = var.tenancy_ocid
  availability_domain = var.availability_domain
  display_name        = "little-gateway"

  # --- This makes it "Always Free" ---
  shape = "VM.Standard.E2.1.Micro"
  shape_config {
    # "Always Free" includes 1 OCPU and 1GB RAM
    ocpus         = 1
    memory_in_gbs = 1
  }

  # Image Source (from our data source)
  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_image.images[0].id

    boot_volume_size_in_gbs = var.boot_volume_size
  }

  # Networking (from our data source)
  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true # So you can SSH to it
    hostname_label   = "littlegateway"
  }

  # --- This is the Cloud-Init part ---
  metadata = {
    # SSH key for access
    ssh_authorized_keys = join("\n", [
      trimspace(file(var.ssh_public_key_path)),
      trimspace(data.bitwarden_secret.github_ci_ansible_ssh_public_key.value)
    ])

    # Cloud-init script, base64 encoded
    user_data = base64encode(templatefile("${path.module}/cloud-init.yaml", {}))
  }
}

# Output the public IP address of the new instance
output "instance_public_ip" {
  value = oci_core_instance.little_gateway.public_ip
}