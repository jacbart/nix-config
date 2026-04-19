{
  config,
  inputs,
  lib,
  ...
}:
{
  nixosHosts.oak = {
    username = "ratatoskr";
    modules = [
      config.flake.modules.nixos.core
      (inputs.nixpkgs + "/nixos/modules/virtualisation/digital-ocean-image.nix")
      ../../nixos/security/acme-proxy.nix
      config.flake.modules.nixos.profileFail2ban
      config.flake.modules.nixos.profileOnlinePersonal
      config.flake.modules.nixos.profileMailrelay
      (
        { pkgs, ... }:
        let
          lm = import ../../nixos/services/mk-leadership-matrix-package.nix { inherit pkgs inputs; };
        in
        {
          services.leadership-matrix.package = lm;

          virtualisation.digitalOceanImage.compressionMethod = "bzip2";
          networking = {
            networkmanager.dns = "none";
            firewall = {
              enable = true;
              allowedTCPPorts = [
                80
                443
                25
                587
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
      )
      ./nginx.nix
    ];
  };
}
