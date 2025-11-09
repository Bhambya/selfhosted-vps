variable region { default = "ap-mumbai-1" }
variable ssh_public_key_path { default = "~/.ssh/gateway.pub" }

variable "s3_endpoint" {
  description = "Endpoint for S3 storage. Get it from BW secret a0bb68fa-f576-4e3c-9f43-b390015ab952"
  type        = string
}

variable "bw_access_token" {
  description = "Access Token for BWS"
  type        = string
  sensitive   = true
}