# attic watch-store: auto-push any store path entering the local Nix store to
# the shared attic cache.  Catches local builds AND outputs copied back from
# remote builders.  Skips paths already on upstream caches (cache.nixos.org
# etc.) by default — attic's filter handles this.
#
# The push JWT is deployed via sops (attic/push-token).  Create it on maple:
#   atticadm make-token --sub <host> --validity '99 years' \
#     --push nix-cache --create-cache nix-cache
# (`attic use` needs pull — granted to every token on a public cache. The
# create-cache scope lets the script below re-create the cache after an
# atticd DB reset instead of crash-looping until an admin intervenes.)
{
  config,
  pkgs,
  lib,
  vars,
  ...
}:
{
  users.users.attic-watch-store = {
    isSystemUser = true;
    group = "attic-watch-store";
  };

  users.groups.attic-watch-store = { };

  sops.secrets."attic/push-token" = {
    owner = "attic-watch-store";
    mode = "0400";
  };

  systemd.services.attic-watch-store = {
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "nix-daemon.service"
    ];
    environment.HOME = "/var/lib/attic-watch-store";
    serviceConfig = {
      User = "attic-watch-store";
      Group = "attic-watch-store";
      MemoryHigh = "5%";
      MemoryMax = "10%";
      LoadCredential = "push-token:${config.sops.secrets."attic/push-token".path}";
      StateDirectory = "attic-watch-store";
      Restart = "on-failure";
      RestartSec = "30s";
    };
    path = [ pkgs.attic-client ];
    script = ''
      set -eux -o pipefail
      ATTIC_TOKEN=$(< "$CREDENTIALS_DIRECTORY/push-token")
      attic login prod https://nix-cache.${vars.domain} "$ATTIC_TOKEN"
      # Self-heal after an atticd DB reset (fresh DB = NoSuchCache).
      # Needs the create-cache scope on the token; a no-op otherwise.
      attic cache create prod:nix-cache 2>/dev/null || true
      attic use prod:nix-cache
      exec attic watch-store prod:nix-cache
    '';
  };
}
