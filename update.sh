#!/usr/bin/env bash
set -e

updated_required="false"

[ $(git rev-parse HEAD) = $(git ls-remote $(git rev-parse --abbrev-ref @{u} | \
sed 's/\// /g') | cut -f1) ] && updated_required="false" || updated_required="true"

if [ "$updated_required" = "false" ]; then
    echo "Lasius is up to date."
    exit 1
fi

if [ "$updated_required" = "true" ]; then
    echo "Lasius is out of date. Updating..."
    git fetch
    git stash
    git pull --rebase
    git stash pop
fi
