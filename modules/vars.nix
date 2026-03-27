{ lib, ... }:
{
  _module.args = {
    vars = {
      domain = "meep.sh";
      email = "jacbart@gmail.com";
      timezone = "America/Phoenix";
      acmeDnsProvider = "cloudflare";
      lanSubnet = "10.120.0.0/24";
      lanGateway = "10.120.0.1";
      lanDomain = "lan.meep.sh";
    };
    stateVersion = lib.mkDefault "25.11";
  };
}
