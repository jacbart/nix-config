{ config, ... }: {
  sops.secrets."cloudflare_api_key" = {
    group = "nginx";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "jacbart@gmail.com";
    certs = {
      "meep.sh" = {
        domain = "meep.sh";
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets."cloudflare_api_key".path;
      };
      "matrix.meep.sh" = {
        domain = "matrix.meep.sh";
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets."cloudflare_api_key".path;
      };
      "tun.meep.sh" = {
        domain = "tun.meep.sh";
        group = "nginx";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets."cloudflare_api_key".path;
      };
    };
  };
}
