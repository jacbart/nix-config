#!/usr/bin/env bash

set -euo pipefail

usage() {
	echo "Usage: $(basename "$0") <hostname> [username]"
	echo ""
	echo "  hostname  Host to install (must have modules/hosts/<hostname>/disks.nix)"
	echo "  username  User to create (default: meep)"
	exit 1
}

TARGET_HOST="${1:-}"
TARGET_USER="${2:-meep}"

if [ -z "$TARGET_HOST" ]; then
	gum style --foreground 1 "ERROR! $(basename "$0") requires a hostname"
	usage
fi

if [ "$(id -u)" -eq 0 ]; then
	gum style --foreground 1 "ERROR! $(basename "$0") should be run as a regular user"
	exit 1
fi

# wait for the network to come up
while ! ping -c 1 -W 1 google.com &>/dev/null; do
	gum style --foreground 3 "Waiting for network..."
	sleep 1
done

REPO_DIR="$HOME/workspace/personal/nix-config"

if [ ! -d "$REPO_DIR/.git" ]; then
	mkdir -p "$(dirname "$REPO_DIR")"
	git clone git@github.com:jacbart/nix-config.git "$REPO_DIR"
fi

pushd "$REPO_DIR" >/dev/null || exit
trap 'popd >/dev/null' EXIT

if [ ! -e "modules/hosts/$TARGET_HOST/disks.nix" ]; then
	gum style --foreground 1 "ERROR! $(basename "$0") could not find modules/hosts/$TARGET_HOST/disks.nix"
	exit 1
fi

sudo true

sudo nix run github:nix-community/disko \
	--extra-experimental-features "nix-command flakes" \
	--no-write-lock-file \
	-- \
	--mode zap_create_mount \
	"modules/hosts/$TARGET_HOST/disks.nix"

sudo nixos-install --no-root-password --flake ".#$TARGET_HOST"

# Rsync nix-config to the target install and set the remote origin to SSH.
sudo rsync -a "$HOME/" "/mnt/home/$TARGET_USER/"
# setup host ssh keys
sudo mkdir -p "/mnt/etc/ssh"
sudo rsync -a "/etc/ssh/" "/mnt/etc/ssh/"
# setup age key
sudo mkdir -p "/mnt/var/lib/sops-nix"
sudo cp "/var/lib/sops-nix/key.txt" "/mnt/var/lib/sops-nix/key.txt"
# setup ssh for root
sudo mkdir -p "/mnt/root/.ssh"
sudo rsync -a "/root/.ssh/" "/mnt/root/.ssh/"

gum style --foreground 2 "Test with \`sudo nixos-enter\` or Reboot the machine to run the system"
