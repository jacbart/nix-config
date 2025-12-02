{
  config,
  inputs,
  pkgs,
  ...
}:
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
        matrix.meep.sh {
          reverse_proxy maple.meep.sh:8008
          log {
            output file /var/log/caddy/access-matrix.meep.sh.log
            format json
          }
        }
        mx.meep.sh {
          reverse_proxy maple.meep.sh:443
          log {
            output file /var/log/caddy/access-mx.meep.sh.log
            format json
          }
        }
      }

      # Listen on port 443 for HTTPS traffic (direct, bypassing Anubis for TLS)
      matrix.meep.sh {
        reverse_proxy maple.meep.sh:8008
        log {
          output file /var/log/caddy/access-matrix.meep.sh.log
          format json
        }
        tls {
          on_demand
        }
      }
      mx.meep.sh {
        reverse_proxy maple.meep.sh:443
        log {
          output file /var/log/caddy/access-mx.meep.sh.log
          format json
        }
        tls {
          on_demand
        }
      }
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
