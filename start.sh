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

echo "Starting lasius in $mode mode..."

echo "Stopping any existing lasius-$mode instances before continuing..."
docker compose --project-name lasius-"$mode" down > /dev/null 2>&1 || true

cd "$mode"
docker compose --project-name lasius-"$mode" pull
docker compose --project-name lasius-"$mode" up -d
cd "$current_dir"
