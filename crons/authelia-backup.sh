#!/bin/bash

set -euo pipefail

docker_data_path="/var/lib/docker-data/authelia/config"

if [ ! -f $docker_data_path/db.sqlite3 ]; then
    echo "DB file not found"
    exit 1
fi

sqlite3 $docker_data_path/db.sqlite3 "VACUUM INTO '$docker_data_path/db_$(date '+%Y%m%d_%H%M%S').sqlite3'"

# only keep the last 2 files
# the backrest snapshots will have older files
find $docker_data_path -regex ".*/db_[0-9]+_[0-9]+\.sqlite3" -type f | sort | head -n -2 | xargs -n1 rm -f
