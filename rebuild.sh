#!/usr/bin/env sh
if [[ ! "$1" =~ ^-.* ]]; then
    host="$1"
    shift
fi
if [ -z "$host" ]; then
    sudo nixos-rebuild switch -v --flake '.#' "$@"
else
    nixos-rebuild -v --flake ".#$host" --target-host "root@$host" --build-host localhost switch "$@"
fi
