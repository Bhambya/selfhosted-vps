#!/bin/bash

set -euo pipefail

docker_data_path="/var/lib/docker-data/lldap"

if [ ! -f $docker_data_path/users.db ]; then
    echo "DB file not found"
    exit 1
fi

sqlite3 $docker_data_path/users.db "VACUUM INTO '$docker_data_path/users_$(date '+%Y%m%d_%H%M%S').db'"

# only keep the last 2 files
# the backrest snapshots will have older files
find $docker_data_path -regex ".*/users_[0-9]+_[0-9]+\.db" -type f | sort | head -n -2 | xargs -n1 rm -f
