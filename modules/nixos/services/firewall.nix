{
  lib,
  config,
  ...
}:
let
  hosts = [
  ];
  tcpPorts = [ ];
  udpPorts = [ ];
in
{
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = lib.optionals (builtins.elem config.networking.hostName hosts) tcpPorts;
      allowedUDPPorts = lib.optionals (builtins.elem config.networking.hostName hosts) udpPorts;
    };
  };
}
