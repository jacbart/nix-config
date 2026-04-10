# Composable NixOS service stacks (imports only). Hosts pick profiles beside core/hardware/security.
{ ... }:
{
  flake.modules.nixos.profileTailscale = { ... }: {
    imports = [ ./services/tailscale.nix ];
  };

  flake.modules.nixos.profileNixupd = { ... }: {
    imports = [ ./services/nixupd-client.nix ];
  };

  flake.modules.nixos.profileLeadershipMatrix = { ... }: {
    imports = [ ./services/leadership-matrix.nix ];
  };

  flake.modules.nixos.profileOnlinePersonal = { ... }: {
    imports = [
      ./services/tailscale.nix
      ./services/nixupd-client.nix
      ./services/leadership-matrix.nix
    ];
  };

  flake.modules.nixos.profileWorkstationMedia = { ... }: {
    imports = [
      ./services/qemu.nix
      ./services/docker.nix
      ./services/bluetooth.nix
      ./services/pipewire.nix
    ];
  };

  flake.modules.nixos.profileFail2ban = { ... }: {
    imports = [ ./services/fail2ban.nix ];
  };

  flake.modules.nixos.profileMailrelay = { ... }: {
    imports = [ ./services/mailrelay.nix ];
  };

  flake.modules.nixos.profileMapleHomelab = { ... }: {
    imports = [
      ./services/minio.nix
      ./services/kiwix-serve.nix
      ./services/postgresql.nix
      ./services/zitadel.nix
      ./services/nextcloud-server.nix
      ./services/books.nix
      ./services/dendrite.nix
      ./services/microbin.nix
      ./services/smartmon.nix
      ./services/leadership-matrix.nix
      ./services/koreader-sync-server.nix
    ];
  };
}
