function open {
  xdg-open "$@" >/dev/null 2>&1
}

alias ip="ip --color --brief"

if [[ $(cat /proc/sys/kernel/osrelease | grep microsoft) ]]; then
  alias copy="clip.exe" #windows
else
  alias copy="xclip -sel clip" #linux
fi

if [ -f /etc/debian_version ]; then
  alias update="sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt-get autoremove"
  alias install="sudo apt-get install"
  alias remove="sudo apt-get autoremove"

  xmodmap ~/.xmodmap > /dev/null 2>&1

elif [ -f /etc/redhat-release ]; then
  alias update="sudo dnf update"
  alias install="sudo dnf install"
  alias remove="sudo dnf remove"
elif [ -f /etc/arch-release ]; then
  alias update="yay -Syu"
  alias install="yay -S"
  alias remove="yay -Rcns"
elif `grep -Fq Amazon /etc/system-release 2> /dev/null`; then
  alias update="sudo yum update"
  alias install="sudo yum install"
  alias remove="sudo yum remove"
elif [ -f /etc/alpine-release ]; then
  alias update="sudo apk update"
  alias install="sudo apk add"
  alias remove="sudo apk del"
elif [ -f /etc/os-release ]; then
  if [ "$DISTRO_ID" = "nixos" ]; then
    alias update="nix_update_packages"
    alias upgrade="nixos_rebuild"
    alias install="nix profile install"
    alias list="nix profile list"
    alias remove="nix profile remove"
    alias clean="sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3 && nix-collect-garbage -d && nix store optimise"
    alias gen-list="sudo nix-env -p /nix/var/nix/profiles/system --list-generations"
    alias gen-clean="sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +3"
  fi
fi
