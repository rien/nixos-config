#!/bin/sh
host="$1"
if [ ! -d "./machines/$host" ]; then
    echo "$host is not configured"
    exit 1
fi

rsync -vrA --exclude=".git/" --exclude=".git-crypt/" --filter=":- .gitignore" . "root@$host:/etc/nixos/"

ssh "root@$host" nixos-rebuild switch
