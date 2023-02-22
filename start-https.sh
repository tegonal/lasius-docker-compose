#!/usr/bin/env bash
set -e

current_dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
mongo_db_key=./https/mongodb/key/mongodb.key
env_file=./https/.env

if [ -f "$mongo_db_key" ]; then
    echo "$mongo_db_key exists."
else
    echo "$mongo_db_key does not exist. Generating key."
    openssl rand -base64 741 > $mongo_db_key
fi

if [ -f "$env_file" ]; then
    echo "$env_file exists."
else
    echo "$env_file does not exist. Copy .env.example to -/http/.env and edit it:"
    echo "cp .env.example $env_file && nano $env_file"
    exit 1
fi

cd https
docker compose --project-name lasius-demo up -d
cd "$current_dir"
