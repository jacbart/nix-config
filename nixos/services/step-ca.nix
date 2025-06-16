{ config
, pkgs
, ...
}:
let
  # stepDir = "/var/lib/step-ca";
  user = "step-ca";
  # group = "step-ca";
in
{
  # systemd.tmpfiles.rules = [
  #   "d ${stepDir} 0755 ${user} ${group}"
  #   "d ${stepDir}/certs 0755 ${user} ${group}"
  #   "d ${stepDir}/config 0755 ${user} ${group}"
  #   "d ${stepDir}/db 0755 ${user} ${group}"
  #   "d ${stepDir}/secrets 0755 ${user} ${group}"
  #   "d ${stepDir}/templates 0755 ${user} ${group}"
  #   "f ${stepDir}/config/defaults.json 0644 ${user} ${group}"
  # ];

  sops.secrets."step_ca/password" = {
    owner = user;
  };

  sops.secrets."step_ca/provisioners" = { };

  services.step-ca = {
    enable = true;
    openFirewall = true;
    package = pkgs.step-ca;
    intermediatePasswordFile = config.sops.secrets."step_ca/password".path;
    address = "127.0.0.2";
    port = 8443;
    settings = builtins.fromJSON (builtins.readFile ./step-ca.json);
  };

  environment.systemPackages = [ pkgs.step-cli ];
}
