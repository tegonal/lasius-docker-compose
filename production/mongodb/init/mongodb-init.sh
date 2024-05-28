#!/bin/sh
set -e

echo "Initialize user"
mongosh <<EOF
use $MONGO_INITDB_DATABASE;
db.createUser({
  user: '$MONGO_INITDB_USERNAME',
  pwd: '$MONGO_INITDB_PASSWORD',
  roles: [{
    role: 'dbOwner',
    db: '$MONGO_INITDB_DATABASE'
  }]
});
EOF
