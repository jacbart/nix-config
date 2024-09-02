{ config, pkgs, ... }: let
  # inherit (pkgs.stdenv) isDarwin;
  # stepDir = if isDarwin then "/User/${username}/.step" else "/home/${username}/.step";
  stepDir = "/var/lib/step-ca";
in {
  # services.nginx = {
  #   enable = true;
    
  # };

  sops.secrets."step/password" = { };

  services.step-ca = {
    enable = true;
    openFirewall = true;
    package = pkgs.step-ca;
    intermediatePasswordFile = config.sops.secrets."step/password".path;
    address = "127.0.0.1";
    port = 8443;
    settings = builtins.fromJSON (builtins.readFile "${stepDir}/config/ca.json");
  };

  environment.systemPackages = [ pkgs.step-cli ];
}
