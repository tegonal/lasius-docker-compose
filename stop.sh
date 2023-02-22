#!/usr/bin/env bash
set -e

if [ "$(uname -m)" != "x86_64" ]; then
    echo "Sorry, Lasius currently only supports x86_64 (amd64) architectures."
    exit 1
fi

if [ -f "lasius.conf" ]; then
    echo "Reading lasius.conf..."
    source lasius.conf
else
    echo "lasius.conf does not exist. Run ./setup.sh first."
    exit 1
fi

docker compose --project-name lasius-"$mode" down

if [ "$mode" = "testing" ]; then
    echo "Removing docker volumes in testing mode ..."
    docker volume rm lasius-"$mode"_db
fi
