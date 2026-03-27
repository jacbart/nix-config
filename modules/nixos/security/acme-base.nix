{ config, vars, ... }:
{
  sops.secrets."cloudflare_api_key" = {
    group = "nginx";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = vars.email;
    certs = {
      "${vars.domain}" = {
        domain = "*.${vars.domain}";
        group = "nginx";
        dnsProvider = vars.acmeDnsProvider;
        environmentFile = config.sops.secrets."cloudflare_api_key".path;
      };
    };
  };
}
