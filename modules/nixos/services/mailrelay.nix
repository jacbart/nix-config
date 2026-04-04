{
  config,
  pkgs,
  vars,
  ...
}:
let
  inherit (vars) domain;
  mapleshIp = "100.116.178.48";
  mapleshPort = 587;
in
{
  environment.systemPackages = with pkgs; [
    postfix
  ];

  postfix = {
    enable = true;
    hostname = "mail.${domain}";
    relayDomains = [ domain ];
    config = {
      mynetworks = [
        "127.0.0.0/8"
        "::1/128"
        "${mapleshIp}"
      ];
      relayhost = "[${mapleshIp}]:${toString mapleshPort}";
      transport_maps = [ "hash:/etc/postfix/transport" ];
      virtual_alias_maps = [ "hash:/etc/postfix/virtual" ];
      owner_request_special = false;
      best_mx_transport = "local";
      disable_dns_lookups = "no";
      alias_maps = [ "hash:/etc/aliases" ];
      mail_spool_directory = "/var/mail";
    };
  };

  systemd.services.postfix = {
    after = [
      "network.target"
      "local-fs.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      PIDFile = "/var/lib/postfix/pid/master.pid";
    };
  };

  networking.firewall.allowedTCPPorts = [
    25 # SMTP
    587 # Submission
  ];

  security.acme.certs."mail.${domain}" = {
    domain = "mail.${domain}";
    dnsProvider = vars.acmeDnsProvider;
    group = "nginx";
    environmentFile = config.sops.secrets."cloudflare_api_key".path;
  };
}
