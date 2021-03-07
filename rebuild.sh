#!/usr/bin/env sh
host="$1"
if [ -z "$host" ]; then
    sudo nixos-rebuild switch -v --flake '.#' "$@"
else
    shift
    nixos-rebuild -v --flake ".#$host" --target-host "root@$host" --build-host localhost switch "$@"
fi
