{ config, vars, ... }:
let
  domain = vars.domain;
  mkCert = certDomain: {
    domain = certDomain;
    dnsProvider = vars.acmeDnsProvider;
    group = "nginx";
    environmentFile = config.sops.secrets."cloudflare_api_key".path;
  };
in
{
  sops.secrets."cloudflare_api_key" = {
    group = "nginx";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = vars.email;
    certs = {
      "${domain}" = mkCert domain;
      "matrix.${domain}" = mkCert "matrix.${domain}";
      "tun.${domain}" = mkCert "tun.${domain}";
    };
  };
}
