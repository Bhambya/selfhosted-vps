data "bitwarden_secret" "restic_repository" {
  id = "9baa12e1-5481-4b11-abe6-b39000cc99cd"
}

data "bitwarden_secret" "restic_aws_access_key_id" {
  id = "a6f69723-99c3-40d1-9888-b39000ca1867"
}

data "bitwarden_secret" "restic_aws_secret_access_key" {
  id = "c9e13db6-5c78-4c62-8110-b39000ca3ea3"
}

data "bitwarden_secret" "restic_repository_password" {
  id = "cf687098-8d02-45de-8490-b39000ca755e"
}

data "bitwarden_secret" "github_ci_ansible_ssh_public_key" {
  id = "6bf6e13d-dfca-4651-9b96-b39000d944b0"
}