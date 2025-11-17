# write_secret_file

Ansible role that creates individual secret files by fetching values from Bitwarden Secrets Manager.

## Requirements

- `bws` (Bitwarden Secrets CLI) installed on the control node
- `jq` installed on the control node
- Bitwarden Secrets Manager access configured

## Role Variables

The role expects an `item` variable with the following structure:

```yaml
item:
  path: "/var/lib/docker-data/app/secret.txt"  # Absolute path for the secret file
  secret: "bitwarden-secret-id"                # Bitwarden secret ID
  mode: "0600"                                 # File permissions (optional, defaults to 600)
  base64: false                                # Whether to base64 decode the secret (optional, defaults to false)
```

## Variable Details

- `path` (required): Absolute path where the secret file will be created
- `secret` (required): Bitwarden Secrets Manager secret ID
- `mode` (optional): File permissions, defaults to `"600"`
- `base64` (optional): If `true`, the secret value will be base64 decoded before writing

## Dependencies

None

## Example Usage

### Basic Secret File

```yaml
- name: Create database password file
  ansible.builtin.include_role:
    name: write_secret_file
  vars:
    item:
      path: "/var/lib/docker-data/postgres/password.txt"
      secret: "postgres-password-id"
      mode: "0400"
```

### Base64 Encoded Secret

```yaml
- name: Create SSL certificate file
  ansible.builtin.include_role:
    name: write_secret_file
  vars:
    item:
      path: "/etc/ssl/certs/app.crt"
      secret: "ssl-cert-base64-id"
      mode: "0644"
      base64: true
```

### Loop Over Multiple Secret Files

```yaml
- name: Create multiple secret files
  ansible.builtin.include_role:
    name: write_secret_file
  loop:
    - path: "/var/lib/docker-data/app/db_password.txt"
      secret: "db-password-id"
    - path: "/var/lib/docker-data/app/api_key.txt"
      secret: "api-key-id"
      mode: "0400"
    - path: "/var/lib/docker-data/app/certificate.pem"
      secret: "cert-base64-id"
      base64: true
  loop_control:
    loop_var: item
```

## Behavior

1. **Directory Creation**: Automatically creates parent directories with mode `700`
2. **Secret Lookup**: Fetches secret from Bitwarden on the control node
3. **Content Processing**: Optionally base64 decodes the secret value
4. **File Creation**: Creates the secret file on the target host with specified permissions

## Error Handling

- Fails if Bitwarden secret lookup fails
- Validates secret retrieval before file creation
- Creates parent directories if they don't exist

## Security Notes

- Secrets are fetched on the control node and transferred securely to target hosts
- Default file permissions are restrictive (`600`)
- Parent directories are created with secure permissions (`700`)