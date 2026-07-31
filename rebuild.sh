#!/usr/bin/env sh
if [[ -n "$1" && ! "$1" =~ ^-.* ]]; then
    host="$1"
    shift
fi
if [ -z "$host" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sudo darwin-rebuild switch --flake '.#' "$@"
    else
        sudo nixos-rebuild switch --flake '.#' "$@"
    fi
else
    nixos-rebuild --flake ".#$host" --target-host "root@$host" switch "$@"
fi
