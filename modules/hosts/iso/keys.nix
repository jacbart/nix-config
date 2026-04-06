{ pkgs, ... }:
let
  service_user = "nixos";

  # Injected at build time via ISO_SSH_KEY and ISO_AGE_KEY env vars (--impure)
  sshkey = pkgs.writeText "meep-ssh-key" (builtins.getEnv "ISO_SSH_KEY");
  agekey = pkgs.writeText "meep-age-key" (builtins.getEnv "ISO_AGE_KEY");
in
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "install" ''
      #! ${pkgs.zsh}/bin/zsh
      set -euo pipefail

      if [ ! -s "${sshkey}" ]; then
        echo "WARNING: ISO_SSH_KEY is empty. Set it at build time to enable git access."
      fi

      if [ ! -s "${agekey}" ]; then
        echo "WARNING: ISO_AGE_KEY is empty. Set it at build time to enable sops decryption."
      fi

      setup_keys() {
        local home="$1"
        local owner="$2"
        local do_sudo="''${3:-}"

        local -a SUDO=()
        if [ "$do_sudo" = "sudo" ]; then
          sudo true
          SUDO=(sudo)
        fi

        $SUDO install -dm0700 "$home/.ssh"
        $SUDO install -Dm0400 -o "$owner" "${sshkey}" "$home/.ssh/id_github"
        $SUDO install -Dm0600 -o "$owner" =(printf 'Host github.com\n  IdentityFile %s/.ssh/id_github\n  User git\n' "$home") "$home/.ssh/config"
        $SUDO install -Dm0600 -o "$owner" "${agekey}" "$home/.config/sops/age/keys.txt"
      }

      setup_keys "$HOME" "${service_user}"
      setup_keys "/root" "root" sudo

      ${pkgs.scripts.install-system}/bin/install-system "$@"
    '')
  ];
}
