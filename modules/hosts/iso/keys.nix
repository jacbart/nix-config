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
      #! ${pkgs.bash}/bin/bash
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

        if [ "$do_sudo" = "sudo" ]; then
          sudo true
          sudo install -dm0700 "$home/.ssh"
          sudo install -Dm0400 -o "$owner" "${sshkey}" "$home/.ssh/id_github"
          printf 'Host github.com\n  IdentityFile %s/.ssh/id_github\n  User git\n' "$home" \
            | sudo tee "$home/.ssh/config" > /dev/null
          sudo chmod 0600 "$home/.ssh/config"
          sudo chown "$owner" "$home/.ssh/config"
          sudo install -Dm0600 -o "$owner" "${agekey}" "$home/.config/sops/age/keys.txt"
        else
          install -dm0700 "$home/.ssh"
          install -Dm0400 -o "$owner" "${sshkey}" "$home/.ssh/id_github"
          printf 'Host github.com\n  IdentityFile %s/.ssh/id_github\n  User git\n' "$home" \
            > "$home/.ssh/config"
          chmod 0600 "$home/.ssh/config"
          chown "$owner" "$home/.ssh/config"
          install -Dm0600 -o "$owner" "${agekey}" "$home/.config/sops/age/keys.txt"
        fi
      }

      setup_keys "$HOME" "${service_user}"
      setup_keys "/root" "root" sudo

      ${pkgs.scripts.install-system}/bin/install-system "$@"
    '')
  ];
}
