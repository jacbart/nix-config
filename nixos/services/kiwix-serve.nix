{ pkgs, ... }:
let
  user = "kiwix";
  group = "kiwix";
  dataDir = "kiwix";
  domain = "meep.sh";
  package = pkgs.kiwix-tools;
  port = 3636;
  listenAddress = "127.0.0.2";
in
{
  environment.systemPackages = [ package ];

  users.users."${user}" = {
    isSystemUser = true;
    inherit group;
    home = "/var/lib/${dataDir}";
  };

  users.groups."${group}" = { };

  systemd.services.kiwix = {
    description = "Host ZIM files on the web with kiwix-serve";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      StateDirectory = dataDir;
      WorkingDirectory = "/var/lib/${dataDir}";
      ExecStart = ''
        ${package}/bin/kiwix-serve --library \
          --port ${builtins.toString port} \
          --address ${listenAddress} \
          --monitorLibrary \
          /var/lib/${dataDir}/library.xml
      '';
      Restart = "on-failure";
    };
  };

  # networking.firewall.allowedTCPPorts = [ port ];
  services.nginx = {
    enable = true;
    virtualHosts."wiki.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:3636";
        proxyWebsockets = true; # needed if you need to use WebSocket
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
          # required when the server wants to use HTTP Authentication
          "proxy_pass_header Authorization;";
      };
    };
  };
}
