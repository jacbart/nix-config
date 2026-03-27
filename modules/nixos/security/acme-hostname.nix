{
  config,
  vars,
  hostname,
  ...
}:
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
      "${hostname}.${domain}" = mkCert "${hostname}.${domain}";
    };
  };
}
