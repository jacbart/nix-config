{ config, ... }: {
  sops.secrets."cloudflare_api_key" = {
    group = "nginx";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jacbart@gmail.com";
    certs = {
      "meep.sh" = {
        domain = "*.proxy.meep.sh";
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets."cloudflare_api_key".path;
      };
    };
  };
}
