#!/bin/sh
host="$1"
if [ ! -d "./machines/$host" ]; then
    echo "$host is not configured"
    exit 1
fi

if [ -s "$(git status --porcelain)" ]; then
    echo "Commit your changes."
    git status
fi

ssh "root@$host" "cd /etc/nixos; git pull; nixos-rebuild switch"
