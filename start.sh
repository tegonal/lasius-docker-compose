#!/usr/bin/env bash
set -e

current_dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source lasius-version.conf

if [ -f "lasius.conf" ]; then
    echo "Reading lasius.conf..."
    source lasius.conf
else
    echo "lasius.conf does not exist. Run ./setup.sh first."
    exit 1
fi

if [ -z "$dockerfile" ]; then
    dockerfile="docker-compose.yml"
fi

echo "Starting lasius in $mode mode with dockerfile $dockerfile..."

echo "Stopping any existing lasius-$mode instances before continuing..."
docker compose -f $dockerfile --project-name lasius-"$mode" down > /dev/null 2>&1 || true

cd "$mode"
sed -i "s/^LASIUS_VERSION=.*/LASIUS_VERSION=$lasius_version/" .env
docker compose -f $dockerfile --project-name lasius-"$mode" pull
docker compose -f $dockerfile --project-name lasius-"$mode" up -d
cd "$current_dir"
