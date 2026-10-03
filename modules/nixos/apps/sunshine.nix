# Sunshine: game-streaming host (Moonlight clients, e.g. ash the uConsole).
{
  config,
  pkgs,
  vars,
  ...
}:
let
  domain = "sunshine.${vars.domain}";
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    # KMS capture (works compositor-independently, needed under niri/nvidia).
    capSysAdmin = true;
    openFirewall = true;
    # Wrap sunshine with CUDA libraries so NVENC encoder works.
    package = pkgs.sunshine.override { cudaSupport = true; };
  };

  # Enable VA-API video acceleration for NVIDIA (nvidia-vaapi-driver).
  hardware.nvidia.videoAcceleration = true;

  # sunshine.meep.sh -> Sunshine web UI (HTTPS, self-signed, :47990) so the
  # config/pairing UI is reachable over Tailscale. nginx terminates TLS with
  # a real LE cert; the upstream is Sunshine's own self-signed HTTPS, so
  # upstream verification is disabled.
  security.acme.certs.${domain} = {
    domain = domain;
    email = vars.email;
    dnsProvider = vars.acmeDnsProvider;
    group = "nginx";
    environmentFile = config.sops.secrets."cloudflare_api_key".path;
  };

  services.nginx = {
    enable = true;
    virtualHosts.${domain} = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "https://127.0.0.1:47990";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_ssl_verify off;
          proxy_set_header Host $host;
          proxy_pass_header Authorization;
        '';
      };
    };
  };

  # nginx listens on 80/443 for the virtual host; open them so the web UI is
  # reachable over Tailscale (the tailscale module only opens UDP 41641).
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
