{ config
, inputs
, pkgs
, ...
}: {
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
      books.meep.sh {
        reverse_proxy 100.81.146.101:443
        log {
          output file /var/log/caddy/access-books.meep.sh.log
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
  # Open Firewall for caddy
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
