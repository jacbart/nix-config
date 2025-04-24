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
      {
        log {
          level ERROR
        }
      }
      matrix.meep.sh {
        log {
          output file /var/log/caddy/access-matrix.meep.sh.log
        }
        forward_proxy {
          basic_auth jack ${config.sops.placeholder."caddy_users/jack_pass"}
          hide_via
          disable_insecure_upstreams_check
          serve_pac /anerlour.pac

          max_idle_conns          3
          max_idle_conns_per_host 2

          upstream http://
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
