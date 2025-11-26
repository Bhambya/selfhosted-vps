#!/bin/bash

set -euo pipefail

# 1. Validation: Check if correct number of arguments are passed
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <database_directory_path> <database_filename>"
    echo "Example: $0 /var/lib/docker-data/authelia/config db.sqlite3"
    exit 1
fi

# 2. Assign Arguments to Variables
# "${1%/}" removes a trailing slash if the user added one (e.g. /path/ -> /path)
DB_DIR="${1%/}"
DB_FILENAME="$2"
DB_FULL_PATH="$DB_DIR/$DB_FILENAME"

# 3. Check if the source database exists
if [ ! -f "$DB_FULL_PATH" ]; then
    echo "Error: DB file not found at $DB_FULL_PATH"
    exit 1
fi

# 4. Extract filename parts for dynamic naming
# If DB_FILENAME is "db.sqlite3":
# NAME_BASE becomes "db"
# EXTENSION becomes "sqlite3"
NAME_BASE="${DB_FILENAME%.*}"
EXTENSION="${DB_FILENAME##*.}"

# Generate timestamp string
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Construct new backup name: db_20230101_120000.sqlite3
BACKUP_NAME="${NAME_BASE}_${TIMESTAMP}.${EXTENSION}"

# 5. Perform the Vacuum/Backup
echo "Backing up $DB_FILENAME to $BACKUP_NAME..."
sqlite3 "$DB_FULL_PATH" "VACUUM INTO '$DB_DIR/$BACKUP_NAME'"

# 6. Cleanup: only keep the last 2 files
# The regex is updated dynamically to match the filename provided.
# Matches: /path/to/dir/filename_NUMBERS_NUMBERS.extension
echo "Cleaning up old backups..."
find "$DB_DIR" -regextype posix-extended -regex ".*/${NAME_BASE}_[0-9]{8}_[0-9]{6}\.${EXTENSION}" -type f | sort | head -n -2 | xargs -r -n1 rm -f

echo "Done."