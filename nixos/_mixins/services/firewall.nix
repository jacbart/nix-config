{ lib, hostname, ... }:
let
  hosts = [
    "cork"
    "maple"
    "oak"
  ];
  tcpPorts = [ ];
  udpPorts = [ ];
in
{
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname hosts) tcpPorts;
      allowedUDPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname hosts) udpPorts;
    };
  };
}
