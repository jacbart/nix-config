{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  nixosHosts.oak = {
    username = "ratatoskr";
    modules = [
      config.flake.modules.nixos.core
      (inputs.nixpkgs + "/nixos/modules/virtualisation/digital-ocean-image.nix")
      ../../nixos/security/acme-proxy.nix
      ../../nixos/services/fail2ban.nix
      ../../nixos/services/leadership-matrix.nix
      ../../nixos/services/tailscale.nix
      ../../nixos/services/nixupd-client.nix
    ]
    ++ [
      {
        services.leadership-matrix = {
          package = inputs.leadership-matrix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
            cargoFeatures = [ "systemd" ];
          };
          services = lib.mkForce [
            "leadership-matrix"
            "nginx"
            "tailscaled"
            "fail2ban"
          ];
        };

        virtualisation.digitalOceanImage.compressionMethod = "bzip2";
        networking = {
          hosts = {
            "127.0.0.2" = [
              "oak.meep.sh"
              "matrix.meep.sh"
              "mx.meep.sh"
              "tun.meep.sh"
            ];
            "100.116.178.48" = [
              "maple.meep.sh"
              "s3.meep.sh"
              "books.meep.sh"
              "auth.meep.sh"
              "minio.meep.sh"
              "cloud.meep.sh"
              "wiki.meep.sh"
            ];
          };
          networkmanager.dns = "none";
          firewall = {
            enable = true;
            allowedTCPPorts = [
              80
              443
            ];
            allowedUDPPorts = [ ];
          };
        };

        services.openssh = {
          ports = [ 3048 ];
          settings.PasswordAuthentication = lib.mkForce false;
          settings.PermitRootLogin = lib.mkForce "yes";
        };
        time.timeZone = lib.mkForce "Europe/Berlin";

        swapDevices = [
          {
            device = "/swap/swapfile";
            size = 1024 * 2; # 2GB
          }
        ];
      }
    ]
    ++ [
      ./nginx.nix
    ];
  };
}
