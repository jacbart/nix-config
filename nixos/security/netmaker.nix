{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.netmaker-full ];

  networking.firewall = {
    allowedTCPPorts = [  ];
  };

  systemd.services.netmaker = {
    description = "Netmaker Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      ExecStart = "${pkgs.netmaker}/bin/netmaker -c /etc/netmaker/netmaker.yml";
    };
  };
}
