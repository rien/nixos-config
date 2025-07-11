#!/usr/bin/env sh
if [[ -n "$1" && ! "$1" =~ ^-.* ]]; then
    host="$1"
    shift
fi
if [ -z "$host" ]; then
    sudo nixos-rebuild switch --flake '.#' "$@"
else
    nixos-rebuild --flake ".#$host" --target-host "root@$host" switch "$@"
fi
