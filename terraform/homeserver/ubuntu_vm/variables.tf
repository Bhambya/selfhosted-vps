variable "proxmox_node" {
  type        = string
  description = "The Proxmox node to create the VM in"
}

variable "hostname" {
  type        = string
  description = "The hostname"
}

variable "cpu_cores" {
  type        = number
  description = "Number of CPU cores"
}

variable "dedicated_memory" {
  type        = number
  description = "Dedicated memory (RAM) in Megabytes"
}

variable "disk_import_from" {
  type        = string
  description = "Image to import from"
}

variable "disk_size" {
  type        = number
  description = "Boot disk size in Gigabytes"
}

variable "ipv4_address" {
  type        = string
  description = "The IPv4 address with subnet"
}

variable "ipv4_gateway" {
  type        = string
  description = "The IPv4 gateway"
}

variable "additional_packages" {
  type        = list(string)
  description = "Additional packages to be installed during cloud-init"
  default     = []
}

variable "additional_rumcmds" {
  type        = list(string)
  description = "Additional commands to run during cloud-init"
  default     = []
}

variable "ufw_allow_rules" {
  type        = list(string)
  description = "ufw rules to be allowed"
  default     = ["ssh"]
}

variable "ssh_authorized_keys" {
  type        = list(string)
  description = "Authorized ssh public keys"
  default     = []
}

