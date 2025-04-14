#!/usr/bin/env bash
set -e

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Sorry, Lasius currently only supports x86_64 (amd64) architectures."
  exit 1
fi

DATE_SUFFIX=$(date +"%Y%m%d")
if [ -f "lasius.conf" ]; then
  while true; do
    read -rp "Config already exists, do you want to start over and create a a new one? This will also reset all the keys, a copy will be created. (y/n) " yn
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
  
  BACKUP_NAME="lasius.conf.bkp_$DATE_SUFFIX"
  cp "lasius.conf" "$BACKUP_NAME"
  echo ""
  echo ">>> Created a copy of the existing lasius.conf to $BACKUP_NAME"
  echo ""
fi

SERVER_VERSION=$(docker version -f "{{.Server.Version}}")
SERVER_VERSION_MAJOR=$(echo "$SERVER_VERSION" | cut -d'.' -f 1)
SERVER_VERSION_MINOR=$(echo "$SERVER_VERSION" | cut -d'.' -f 2)
SERVER_VERSION_BUILD=$(echo "$SERVER_VERSION" | cut -d'.' -f 3 | cut -d'+' -f 1 | cut -d'~' -f 1 | cut -d'-' -f 1)

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
echo "Additionally, if you choose production mode, you will be asked if you want "
echo "to require users to accept your Terms of Service before using Lasius."
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
    read -rp "Start lasius in https mode (with lets-encrypt certificate)? (y/n) " yn
    case $yn in
    [Yy]*)
      dockerfile="docker-compose.yml"
      baseurl="https://\${LASIUS_HOSTNAME:-localhost}\${LASIUS_PORT_HTTPS:+:\$LASIUS_PORT_HTTPS}"
      break
      ;;
    [Nn]*)
      dockerfile="docker-compose-no-https.yml"
      baseurl="http://\${LASIUS_HOSTNAME:-localhost}\${LASIUS_PORT_HTTP:+:\$LASIUS_PORT_HTTP}"
      break
      ;;
    *) echo "Please answer with (y)es or (n)o" ;;
    esac
  done

  mkdir -p ./$mode/termsofservice
  while true; do
    read -rp "Do you want to require users to accept Terms of Services before they are able to use Lasius? (y/n) " yn
    case $yn in
    [Yy]*)
      termsofservice="1.0"
      cp -n ./templates/termsofservice/* ./$mode/termsofservice/
      echo ""
      echo "NOTE: Please edit the following files to reflect your Terms of Service:"
      echo ""
      for F in `ls $mode/termsofservice/*.html` ; do
        echo "     - $F"
      done
      echo ""
      echo "If you update those files later, you also have to change LASIUS_TERMSOFSERVICE_VERSION in"
      echo "./$mode/.env in order to require users to accept the updated version of the terms."
      break
      ;;
    [Nn]*)
      termsofservice=""
      break
      ;;
    *) echo "Please answer with (y)es or (n)o" ;;
    esac
  done
fi
echo ""

if [ "$mode" == "testing" ]; then
  while true; do
    read -rp "Please enter a port: (press enter to use 8080) " input
    if [ -z "$input" ]; then
      local_http_port="8080"
      break
    else
      local_http_port=$input
      break
    fi
  done

  dockerfile="docker-compose.yml"
fi
echo ""

mongo_db_key=$(openssl rand -base64 741)
mongo_db_pw=$(openssl rand -hex 16 | tr -d '\n')
next_auth_key=$(openssl rand -base64 96 | tr -d '\n')

mongo_admin_db_pw=$(openssl rand -hex 32 | tr -d '\n')
postgres_admin_db_pw=$(openssl rand -hex 32 | tr -d '\n')

# internal oauth provider secrets
oauth_client_id=$(openssl rand -hex 16 | tr -d '\n')
oauth_client_secret=$(openssl rand -hex 16 | tr -d '\n')
oauth_jwt_private_key=$(openssl rand -hex 16 | tr -d '\n')

keycloak_admin_pwd=$(openssl rand -hex 32 | tr -d '\n')
keycloak_client_secret=$(openssl rand -hex 32 | tr -d '\n')

echo "Saving configuration to lasius.conf ..."
echo "mode=$mode" >lasius.conf
echo "dockerfile=$dockerfile" >>lasius.conf
echo ""

mongo_db_key_file=./$mode/mongodb/key/mongodb.key
echo "$mongo_db_key" >"$mongo_db_key_file"

env_file="./$mode/.env"

if [ -f "$env_file" ]; then
  BACKUP_NAME="${env_file}_$DATE_SUFFIX"
  cp "$env_file" "$BACKUP_NAME"
  echo ""
  echo ">>> Created a copy of the existing $env_file to $BACKUP_NAME"
  echo ""
fi

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
echo "LASIUS_PORT_HTTPS=" >>$env_file
if [ "$local_http_port " != "80" ]; then
  echo "LASIUS_PORT_HTTP=$local_http_port" >>$env_file
fi
echo "MONGO_HOST=mongodb:27017" >>$env_file
echo "MONGO_INITDB_PASSWORD=$mongo_db_pw" >>$env_file
echo "MONGO_INITDB_ROOT_USERNAME=admin" >>$env_file
echo "MONGO_INITDB_ROOT_PASSWORD=$mongo_admin_db_pw" >>$env_file
echo "MONGO_INITDB_USERNAME=lasius" >>$env_file
echo "POSTGRES_DB_NAME=lasius-keycloak" >>$env_file
echo "POSTGRES_DB_USERNAME=admin" >>$env_file
echo "POSTGRES_DB_PASSWORD=$postgres_admin_db_pw" >>$env_file
echo "LASIUS_OAUTH_CLIENT_ID=$oauth_client_id" >>$env_file
echo "LASIUS_OAUTH_CLIENT_SECRET=$oauth_client_secret" >>$env_file
echo "LASIUS_INTERNAL_JWT_PRIVATE_KEY=$oauth_jwt_private_key" >>$env_file
echo "NEXTAUTH_SECRET=$next_auth_key" >>$env_file
echo "LASIUS_TERMSOFSERVICE_VERSION=\"$termsofservice\"" >>$env_file

# add local keycloak configuration
if [ "$mode" == "production" ]; then
  echo "KEYCLOAK_OAUTH_ISSUER=$baseurl/keycloak/realms/lasius" >>$env_file
  echo "KEYCLOAK_OAUTH_URL=http://keycloak:8080/keycloak/realms/lasius" >>$env_file
  echo "KEYCLOAK_OAUTH_CLIENT_ID=lasius-frontend" >>$env_file
  echo "KEYCLOAK_OAUTH_CLIENT_SECRET=$keycloak_client_secret" >>$env_file
  echo "KEYCLOAK_ADMIN_PWD=$keycloak_admin_pwd" >>$env_file
fi

echo "Done. You can now start Lasius with the start.sh script."
