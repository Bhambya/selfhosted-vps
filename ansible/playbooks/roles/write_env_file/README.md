# write_env_file

Ansible role that creates environment files by combining fixed values, Ansible variables, and secrets from Bitwarden Secrets Manager.

## Requirements

- `bws` (Bitwarden Secrets CLI) installed on the control node
- `jq` installed on the control node
- Bitwarden Secrets Manager access configured

## Role Variables

The role expects an `env_file` variable with the following structure:

```yaml
env_file:
  relative_path: "docker/.env"  # Path relative to repo_path
  mode: "0600"                  # File permissions
  fixed:                        # Static key-value pairs
    COMPOSE_PROJECT_NAME: "homelab"
    ENVIRONMENT: "production"
  vars:                         # Values from Ansible variables
    DOMAIN: "domain_name"       # Uses {{ domain_name }} variable
    USER_ID: "user_id"          # Uses {{ user_id }} variable
  secrets:                      # Values from Bitwarden Secrets Manager
    DB_PASSWORD: "db-secret-id" # Fetches secret with ID "db-secret-id"
    API_KEY: "api-secret-id"    # Fetches secret with ID "api-secret-id"
```

## Dependencies

- `repo_path` variable must be defined (target directory path)

## Example Usage

```yaml
- name: Create application environment file
  ansible.builtin.include_role:
    name: write_env_file
  vars:
    env_file:
      relative_path: "docker/.env"
      mode: "0600"
      fixed:
        COMPOSE_PROJECT_NAME: "myapp"
        LOG_LEVEL: "info"
      vars:
        DOMAIN: "app_domain"
        PORT: "app_port"
      secrets:
        DATABASE_PASSWORD: "{{ db_secret_id }}"
        JWT_SECRET: "{{ jwt_secret_id }}"
```

## Generated File Format

The role generates an environment file with the following format:

```bash
# Fixed values
COMPOSE_PROJECT_NAME='myapp'
LOG_LEVEL='info'

# Variable values
DOMAIN='example.com'
PORT='8080'

# Secret values (fetched from Bitwarden)
DATABASE_PASSWORD='secret_password_value'
JWT_SECRET='jwt_token_value'
```

## Error Handling

- Fails if any Bitwarden secret lookup fails
- Validates secret retrieval before proceeding with file creation
- Uses `break_when` to stop on first secret lookup failure