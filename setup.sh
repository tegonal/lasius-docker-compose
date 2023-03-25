#!/usr/bin/env bash
set -e

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Sorry, Lasius currently only supports x86_64 (amd64) architectures."
  exit 1
fi

if [ -f "lasius.conf" ]; then
  while true; do
    read -rp "Config already exists, do you want to start over and create a a new one? This will also reset all the keys. (y/n) " yn
    case $yn in
    [Yy]*)
      break
      ;;
    [Nn]*)
      exit 1
      ;;
    *) echo "Please answer with (y)es or (n)o" ;;
    esac
  done
fi

SERVER_VERSION=$(docker version -f "{{.Server.Version}}")
SERVER_VERSION_MAJOR=$(echo "$SERVER_VERSION" | cut -d'.' -f 1)
SERVER_VERSION_MINOR=$(echo "$SERVER_VERSION" | cut -d'.' -f 2)
SERVER_VERSION_BUILD=$(echo "$SERVER_VERSION" | cut -d'.' -f 3)

if [ "${SERVER_VERSION_MAJOR}" -ge 20 ] &&
  [ "${SERVER_VERSION_MINOR}" -ge 0 ] &&
  [ "${SERVER_VERSION_BUILD}" -ge 0 ]; then
  echo "Docker version $SERVER_VERSION: Splendid!"
else
  echo "Docker version needs to be 20.0.0 or higher. You have $SERVER_VERSION."
  echo "Please update your docker installation."
  exit 1
fi

current_dir="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

mode="testing"
hostname="localhost"
local_http_port="80"

echo ""
echo "Welcome to the Lasius setup script."
echo "Please make sure you have read the README.md file before continuing."
echo ""

echo "Production mode or testing mode"
echo "======================================"
echo "Lasius can be run in two modes: production or testing. Production mode will"
echo "run Lasius on a public hostname on standard ports (80/443) with an empty DB."
echo "Localhost mode is intended for development/testing or demo purposes."
echo ""
echo "If you choose production mode, you will be asked to enter a hostname. This hostname"
echo "will be used to generate a certificate for your server. If you choose testing"
echo "mode, you will be asked to enter a HTTP port."
echo ""
echo "Additionally, if you choose production mode, you will be asked to enter an e-mail"
echo "and password. This will be your initial \"root\" user."
echo ""
while true; do
  read -rp "Start lasius in production mode? (y/n) " yn
  case $yn in
  [Yy]*)
    mode="production"
    break
    ;;
  [Nn]*)
    mode="testing"
    break
    ;;
  *) echo "Please answer with (y)es or (n)o" ;;
  esac
done

if [ "$mode" == "production" ]; then
  while true; do
    read -rp "Please enter a hostname:" input
    if [ -z "$input" ]; then
      echo "Please enter a hostname."
    else
      hostname=$input
      break
    fi
  done
  echo ""

  while true; do
    read -rp "Please enter an e-mail for the admin user, this will be your login: " input
    if [ -z "$input" ]; then
      echo "Please enter an e-mail."
    else
      admin_user=$input
      break
    fi
  done
  echo ""

  while true; do
    read -rp "Please enter a password for the admin user: " input
    if [ -z "$input" ]; then
      echo "Please enter an password."
    else
      admin_pw=$input
      break
    fi
  done
fi
echo ""

if [ "$mode" == "testing" ]; then
  while true; do
    read -rp "Please enter a port: (press enter to use 8080) " input
    if [ -z "$input" ]; then
      local_http_port="8080"
    else
      local_http_port=$input
      break
    fi
  done
fi
echo ""

mongo_db_key=$(openssl rand -base64 741)
mongo_db_pw=$(openssl rand -base64 32 | tr -d '\n')
next_auth_key=$(openssl rand -base64 96 | tr -d '\n')

echo "Saving configuration to lasius.conf ..."
echo "mode=$mode" >lasius.conf
echo ""

mongo_db_key_file=./$mode/mongodb/key/mongodb.key
echo "$mongo_db_key" >"$mongo_db_key_file"

env_file=./$mode/.env

echo "LASIUS_HOSTNAME=$hostname" >$env_file
echo "LASIUS_INSTANCE=lasius-$mode" >>$env_file

if [ "$mode" == "testing" ]; then
  echo "LASIUS_DEMO_MODE=true" >>$env_file
fi

if [ "$mode" == "production" ]; then
  echo "LASIUS_DEMO_MODE=false" >>$env_file
fi

echo "LASIUS_TELEMETRY_MATOMO_HOST=" >>$env_file
echo "LASIUS_TELEMETRY_MATOMO_ID=" >>$env_file
echo "LASIUS_VERSION=" >>$env_file
echo "LASIUS_PORT_HTTPS=443" >>$env_file
echo "LASIUS_PORT_HTTP=$local_http_port" >>$env_file
echo "MONGO_HOST=mongodb:27017" >>$env_file
echo "MONGO_INITDB_PASSWORD=$mongo_db_pw" >>$env_file
echo "MONGO_INITDB_USERNAME=lasius" >>$env_file
echo "NEXTAUTH_SECRET=$next_auth_key" >>$env_file
echo "LASIUS_INITIAL_USER_EMAIL=$admin_user" >>$env_file
echo "LASIUS_INITIAL_USER_PW=$admin_pw" >>$env_file
echo "LASIUS_INITIAL_USER_KEY=admin" >>$env_file

echo "Done. You can now start Lasius with the start.sh script."
