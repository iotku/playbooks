#!/usr/bin/env bash
set -euo pipefail

    rsync -av --progress /etc/nixos/ "./$1" --exclude 'wireguard.nix' --exclude 'hardware-configuration.nix'
