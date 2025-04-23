{ config
, lib
, pkgs ? import <nixpkgs>
, ...
}:
let
  inherit (lib) mkDefault;
in
{
  sops.secrets."tailscale/auth-key" = { };

  systemd.services.tailscaled.after = ["systemd-networkd-wait-online.service"];
  services.tailscale = {
    enable = true;
    interfaceName = mkDefault "tailscale0";
    package = mkDefault pkgs.unstable.tailscale;
    port = mkDefault 0; # 0 = autoselect
    openFirewall = mkDefault true;
    useRoutingFeatures = mkDefault "client"; # "none", "client", "server", or "both"
    extraUpFlags = mkDefault [ "--accept-routes" ];
    authKeyFile = config.sops.secrets."tailscale/auth-key".path;
  };
}
