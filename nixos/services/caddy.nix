{ writeText
, ...
}: {
  systemd.services.caddy.serviceConfig = {
    # https://serverfault.com/a/899964
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
  };

  services.caddy = {
    enable = true;
    configFile = writeText "CaddyFile" ''
      {
        log {
          level ERROR
        }
      }
      matrix.meep.sh {
        log {
          output file /var/log/caddy/access-ai.bbl.systems.log
        }
        reverse_proxy http://100.81.146.101
      }
    '';
  };
}
