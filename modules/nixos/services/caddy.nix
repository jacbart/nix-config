{
  config,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}:
let
  inherit (vars) serviceCatalog;
  edgeRoutes = with serviceCatalog; [
    matrixEdge
    mxEdge
  ];
  mkAnubisServerBlock = route: ''
    ${route.publicHost} {
      reverse_proxy ${route.backendTarget}
      log {
        output file /var/log/caddy/access-${route.accessLogBase}.log
        format json
      }
    }
  '';
  mkTlsServerBlock = route: ''
    ${route.publicHost} {
      reverse_proxy ${route.backendTarget}
      log {
        output file /var/log/caddy/access-${route.accessLogBase}.log
        format json
      }
      tls {
        on_demand
      }
    }
  '';
in
{
  sops.secrets."caddy_users/jack_pass" = {
    owner = "caddy";
    group = "caddy";
    restartUnits = [ "caddy.service" ];
  };
  systemd.services.caddy.serviceConfig = {
    # https://serverfault.com/a/899964
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
  };
  systemd.services.caddy.after = [ "tailscaled.service" ];

  sops.templates.Caddyfile = {
    restartUnits = [ "caddy.service" ];
    content = ''
      # Listen on port 8080 for HTTP traffic from Anubis
      :8080 {
        ${lib.concatStrings (map mkAnubisServerBlock edgeRoutes)}
      }

      # Listen on port 443 for HTTPS traffic (direct, bypassing Anubis for TLS)
      ${lib.concatStrings (map mkTlsServerBlock edgeRoutes)}
    '';
    owner = "caddy";
    group = "caddy";
  };

  services.caddy = {
    enable = true;
    # patched with cloudflare provider
    package = inputs.caddy-with-modules.packages.${pkgs.stdenv.hostPlatform.system}.caddy;
    configFile = config.sops.templates.Caddyfile.path;
  };
  # Caddy listens on 8080 (for Anubis) and 443 (for HTTPS)
  # Port 80 is handled by Anubis
  networking.firewall.allowedTCPPorts = [
    443
  ];
}
