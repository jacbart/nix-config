{ config
, lib
, pkgs ? import <nixpkgs>
, ...
}:
let
  inherit (lib) mkDefault;
  login_server = "hs.meep.sh";
in
{
  sops.secrets."tailscale/api-key" = { };

  services.tailscale = {
    enable = true;
    interfaceName = mkDefault "tailscale0";
    package = mkDefault pkgs.tailscale;
    port = mkDefault 0; # 0 = autoselect
    openFirewall = mkDefault true;
    useRoutingFeatures = mkDefault "client"; # "none", "client", "server", or "both"
    extraUpFlags = mkDefault [ "--login-server" "https://${login_server}" "--accept-routes" ];
    authKeyFile = config.sops.secrets."tailscale/api-key".path;
    authKey = mkDefault {
      baseURL = "https://${login_server}";
      ephemeral = mkDefault null;
      preauthorized = mkDefault null;
    };
  };
}
