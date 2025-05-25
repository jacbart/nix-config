{ pkgs, ... }:
let
  user = "kiwix";
  group = "kiwix";
  dataDir = "kiwix";
  package = pkgs.kiwix-tools;
  port = 3636;
  listenAddress = "192.168.1.5";
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

  networking.firewall.allowedTCPPorts = [ port ];
}
