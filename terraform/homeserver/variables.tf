variable "ssh_public_key_path" {
  description = "Local SSH public key to authorize"
  type        = string
}

variable "base_domain" {
  description = "Your homelab TLD. Eg. example.com"
  type        = string
  sensitive   = true
}

variable "s3_endpoint" {
  description = "Endpoint for S3 state storage. Get it from BW secret a0bb68fa-f576-4e3c-9f43-b390015ab952"
  type        = string
}

variable "bw_access_token" {
  description = "Access Token for BWS"
  type        = string
  sensitive   = true
}

variable "proxmox_api_url" {
  type        = string
  description = "The URL for the Proxmox API (e.g., https://pve.example.com:8006/api2/json)"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "The secret for the Proxmox API Token."
  sensitive   = true # Marks this as sensitive in Tofu output
}
