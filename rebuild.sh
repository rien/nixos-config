#!/usr/bin/env sh
host="$1"
if [ -z "$host" ]; then
    sudo nixos-rebuild switch --flake '.#' "$@"
else
    shift
    nixos-rebuild --flake ".#$host" --target-host "root@$host" --build-host localhost switch "$@"
fi
