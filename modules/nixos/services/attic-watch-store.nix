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
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "nix-daemon.service"
      # Start only once the cache backend is actually reachable, otherwise
      # `attic use`/`attic cache create` get a 502 during a switch and the
      # unit fails activation.
      "atticd.service"
      "nginx.service"
    ];
    environment.HOME = "/var/lib/attic-watch-store";
    serviceConfig = {
      User = "attic-watch-store";
      Group = "attic-watch-store";
      MemoryHigh = "5%";
      MemoryMax = "10%";
      LoadCredential = "push-token:${config.sops.secrets."attic/push-token".path}";
      StateDirectory = "attic-watch-store";
      # The attic client panics on a failed upload (upstream bug), so a crash
      # is expected occasionally.  Back off exponentially instead of re-hitting
      # the cache every 30s and re-amplifying load.
      Restart = "on-failure";
      RestartMode = "exponential";
      RestartSec = "30s";
      RestartMaxDelaySec = "30min";
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
