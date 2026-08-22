# Composable NixOS service stacks (imports only). Hosts pick profiles beside core/hardware/security.
{ ... }:
{
  flake.modules.nixos.profileTailscale =
    { ... }:
    {
      imports = [ ./services/tailscale.nix ];
    };

  flake.modules.nixos.profileOnlinePersonal =
    { ... }:
    {
      imports = [
        ./services/tailscale.nix
        ./services/leadership-matrix.nix
      ];
    };

  flake.modules.nixos.profileWorkstationMedia =
    { ... }:
    {
      imports = [
        ./services/binfmt.nix
        ./services/docker.nix
        ./services/bluetooth.nix
        ./services/pipewire.nix
      ];
    };

  flake.modules.nixos.profileFail2ban =
    { ... }:
    {
      imports = [ ./services/fail2ban.nix ];
    };

  flake.modules.nixos.profileMailrelay =
    { ... }:
    {
      imports = [ ./services/mailrelay.nix ];
    };

  flake.modules.nixos.profileMapleHomelab =
    { lib, ... }:
    {
      imports = [
        ./services/attic.nix
        ./services/mailserver.nix
        ./services/maildns.nix
        ./services/got.nix
        ./services/freshrss.nix
        ./services/rustfs.nix
        ./services/kiwix-serve.nix
        ./services/postgresql.nix
        ./services/zitadel.nix
        ./services/sftpgo.nix
        ./services/books.nix
        ./services/dendrite.nix
        ./services/microbin.nix
        ./services/smartmon.nix
        ./services/leadership-matrix.nix
        ./services/immich.nix
      ];

      systemd.services =
        lib.genAttrs
          [
            "atticd"
            "audiobookshelf"
            "calibre-web-automated"
            "calibre-web-automated-watcher"
            "dendrite"
            "got"
            "immich-server"
            "kiwix-serve"
            "microbin"
            "postgresql"
            "postgresql-backup"
            "rustfs"
            "sftpgo"
          ]
          (_: {
            requires = [ "zfs-mount.service" ];
            after = [ "zfs-mount.service" ];
          });
    };

  # Auto-push anything entering the local Nix store to the attic cache.
  # Import on every host that builds (locally or via remote delegation) so
  # built + copied-back paths populate the shared cache.  Uses attic's
  # `watch-store` which skips paths already on upstream caches by default.
  flake.modules.nixos.profileAtticWatchStore =
    { ... }:
    {
      imports = [ ./services/attic-watch-store.nix ];
    };
}
