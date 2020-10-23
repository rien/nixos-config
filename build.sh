#!/bin/sh
host="$1"
if [ ! -d "./machines/$host" ]; then
    echo "$host is not configured"
    exit 1
fi

# Ensure (confident) files are only accessible by owner
chmod g-rwx,o-rwx ./secrets/

rsync -vrA --delete --exclude=".git/" --exclude "configuration.nix" --exclude=".git-crypt/" --filter=":- .gitignore" . "root@$host:/etc/nixos/"

ssh "root@$host" nixos-rebuild switch --show-trace
