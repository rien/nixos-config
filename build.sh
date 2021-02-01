#!/bin/sh
host="$1"

if [ ! -d "./machines/$host" ]; then
    echo "$host is not configured"
    exit 1
fi

# Ensure (confidential) files are only accessible by owner
chmod g-rwx,o-rwx ./secrets/

rsync -vrA --delete --exclude=".git/" --exclude=".git-crypt/" --filter=":- .gitignore" . "root@$host:/etc/nixos/"

ssh "root@$host" "cd /etc/nixos/ && nixos-rebuild switch --flake '.#'"
