{ pkgs
, ... }:
let
  user = "kiwix";
  group = "kiwix";
  dataDir = "kiwix";
  package = pkgs.kiwix-tools;
  port = 3636;
  listenAddress = "0.0.0.0";
in {
  environment.systemPackages = [ package ];

  users.users."${user}" = {
    isSystemUser = true;
    inherit group;
    home = "/var/lib/${dataDir}";
  };

  users.groups."${group}" = { };

  systemd.services.kiwix = {
    description = "Serve ZIM files with kiwix";
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
          --blockexternal \
          --monitorLibrary \
          ./library.xml
      '';
      Restart = "on-failure";
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
