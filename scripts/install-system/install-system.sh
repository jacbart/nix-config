#!/usr/bin/env bash

set -euo pipefail

TARGET_HOST="${1:-}"
TARGET_USER="${2:-meep}"

if [ "$(id -u)" -eq 0 ]; then
  gum style --foreground 1 "ERROR! $(basename "$0") should be run as a regular user"
  exit 1
fi

# wait for the network to come up
while ! ping -c 1 -W 1 google.com &>/dev/null; do
  gum style --foreground 3 "Waiting for network..."
  sleep 1
done

if [ ! -d "$HOME/nix-config/.git" ]; then
  git clone git@github.com:jacbart/nix-config.git "$HOME/nix-config"
fi

pushd "$HOME/nix-config" >/dev/null || exit

if [[ -z "$TARGET_HOST" ]]; then
  gum style --foreground 1 "ERROR! $(basename "$0") requires a hostname as the first argument"
  exit 1
fi

if [[ -z "$TARGET_USER" ]]; then
  gum style --foreground 1 "ERROR! $(basename "$0") requires a username as the second argument"
  exit 1
fi

if [ ! -e "nixos/hosts/$TARGET_HOST/disks.nix" ]; then
  gum style --foreground 1 "ERROR! $(basename "$0") could not find the required nixos/hosts/$TARGET_HOST/disks.nix"
  exit 1
fi

sudo true

sudo nix run github:nix-community/disko \
  --extra-experimental-features "nix-command flakes" \
  --no-write-lock-file \
  -- \
  --mode zap_create_mount \
  "nixos/hosts/$TARGET_HOST/disks.nix"

sudo nixos-install --no-root-password --flake ".#$TARGET_HOST"

# Rsync nix-config to the target install and set the remote origin to SSH.
sudo rsync -a --delete "$HOME/" "/mnt/home/$TARGET_USER/"
# setup age key
sudo mkdir -p "/mnt/var/lib/sops-nix"
sudo mv "/root/.config/sops/age/key.txt" "/mnt/var/lib/sops-nix/key.txt"
# setup ssh for root
sudo mkdir -p "/mnt/root/.ssh"
sudo rsync -a --delete "/root/.ssh/" "/mnt/root/.ssh/"

gum style --foreground 2 "Reboot the machine"
