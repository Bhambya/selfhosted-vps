#!/bin/bash

set -euo pipefail

CONTAINER_NAME=""
DB_USER=""
DB_PASSWORD=""
DB_NAME=""
BACKUP_DIR=""
BACKUP_RETAIN_COUNT="2"

# Usage function
usage() {
    echo "Usage: $0 -c <container_name> -u <db_user> -p <db_password> -d <db_name> -b <backup_dir> -k <count>"
    echo "Options:"
    echo "  -c <container_name>   Docker container name (Required)"
    echo "  -u <db_user>          PostgreSQL user (Required)"
    echo "  -p <db_password>      PostgreSQL password (Required)"
    echo "  -d <db_name>          Database name or 'all' (Required)"
    echo "  -b <backup_dir>       Directory to store backups (Required)"
    echo "  -k <count>            Number of backups to keep (default: 2)"
    echo "  -h                    Show this help message"
    exit 1
}

# Parse command line arguments
while getopts "c:u:p:d:b:k:h" opt; do
    case $opt in
        c) CONTAINER_NAME="$OPTARG" ;;
        u) DB_USER="$OPTARG" ;;
        p) DB_PASSWORD="$OPTARG" ;;
        d) DB_NAME="$OPTARG" ;;
        b) BACKUP_DIR="$OPTARG" ;;
        k) BACKUP_RETAIN_COUNT="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Validate that all required arguments are provided
if [[ -z "$CONTAINER_NAME" || -z "$DB_USER" || -z "$DB_PASSWORD" || -z "$DB_NAME" || -z "$BACKUP_DIR" ]]; then
    echo "Error: One or more required arguments are missing."
    [[ -z "$CONTAINER_NAME" ]] && echo "  Missing: -c <container_name>"
    [[ -z "$DB_USER" ]] && echo "  Missing: -u <db_user>"
    [[ -z "$DB_PASSWORD" ]] && echo "  Missing: -p <db_password>"
    [[ -z "$DB_NAME" ]] && echo "  Missing: -d <db_name>"
    [[ -z "$BACKUP_DIR" ]] && echo "  Missing: -b <backup_dir>"
    [[ -z "$BACKUP_RETAIN_COUNT" ]] && echo "  Missing: -k <count>"
    echo ""
    usage
fi

# ==============================================================================
# SCRIPT LOGIC
# ==============================================================================

# Date format for the filename (e.g., 2023-10-27_14-00-00)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# 1. Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# 2. Define the filename
if [ "$DB_NAME" == "all" ]; then
    FILENAME="pg_dumpall_${TIMESTAMP}.sql.gz"
else
    FILENAME="${DB_NAME}_${TIMESTAMP}.sql.gz"
fi

FULL_PATH="${BACKUP_DIR}/${FILENAME}"

echo "[$(date)] Starting backup for container: $CONTAINER_NAME..."

# 3. execute the backup
# We pipe the output of docker exec directly to gzip to save space immediately
if [ "$DB_NAME" == "all" ]; then
    # Backup entire instance (all databases)
    if docker exec -e PGPASSWORD="$DB_PASSWORD" "$CONTAINER_NAME" pg_dumpall -c -U "$DB_USER" | gzip > "$FULL_PATH"; then
        echo "[$(date)] SUCCESS: Backup saved to $FULL_PATH"
    else
        echo "[$(date)] ERROR: Backup failed!"
        exit 1
    fi
else
    # Backup specific database
    if docker exec -e PGPASSWORD="$DB_PASSWORD" "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$FULL_PATH"; then
        echo "[$(date)] SUCCESS: Backup saved to $FULL_PATH"
    else
        echo "[$(date)] ERROR: Backup failed!"
        exit 1
    fi
fi

# 4. Clean up old backups
echo "[$(date)] Keeping only the last $BACKUP_RETAIN_COUNT backups, cleaning up older ones..."
ls -tp "$BACKUP_DIR"/*.sql.gz | grep -v '/$' | tail -n +$(($BACKUP_RETAIN_COUNT + 1)) | xargs -I {} rm -- "{}"

echo "[$(date)] Backup process completed."