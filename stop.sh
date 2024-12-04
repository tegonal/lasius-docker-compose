#!/usr/bin/env bash
set -e

current_dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ -f "lasius.conf" ]; then
    echo "Reading lasius.conf..."
    source lasius.conf
else
    echo "lasius.conf does not exist. Run ./setup.sh first."
    exit 1
fi

cd "$mode"
docker compose --project-name lasius-"$mode" down
cd "$current_dir"

if [ "$mode" = "testing" ]; then
    echo "Removing docker volumes in testing mode ..."
    docker volume rm lasius-"$mode"_db
fi
