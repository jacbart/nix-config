{
  config,
  pkgs,
  vars,
  ...
}:
let
  inherit (vars) domain;
  user = "vmail";
  group = "vmail";
  dataDir = "mail";
  relayPort = 2525;
  oakIp = "100.116.178.48";
in
{
  users.users."${user}" = {
    isSystemUser = true;
    inherit group;
    home = "/var/lib/${dataDir}";
    description = "Virtual mail user";
  };

  users.groups."${group}" = { };

  sops.secrets."mail-password" = {
    owner = user;
    group = group;
    mode = "0600";
  };

  environment.systemPackages = with pkgs; [
    dovecot
    postfix
    rspamd
    opendkim
  ];

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

  postfix = {
    enable = true;
    hostname = "mail.${domain}";
    domain = domain;
    destination = [
      domain
      "localhost"
    ];
    config = {
      mynetworks = [
        "127.0.0.0/8"
        "::1/128"
        "${oakIp}"
      ];
      mailbox_size_limit = 0;
      message_size_limit = 52428800;
      alias_maps = [ "hash:/etc/aliases" ];
      virtual_alias_maps = [ "hash:/var/lib/postfix/virtual" ];
      transport_maps = [ "hash:/var/lib/postfix/transport" ];
      receive_override_options = [ "no_address_mappings" ];
    };
  };

  services.dovecot2 = {
    enable = true;
    enableImap = true;
    enablePop3 = false;
    enableLmtp = false;
    enableLda = false;
    protocols = [ "imap" ];
    authMechanisms = [
      "plain"
      "login"
    ];
    mailUser = user;
    ssl = {
      enable = true;
      cert = "/var/lib/acme/certs/mail.${domain}/fullchain.pem";
      key = "/var/lib/acme/private/mail.${domain}/key.pem";
    };
    userdb = {
      name = "passwd";
      args = [ "scheme=CRYPT" ];
    };
    passdb = {
      name = "passwd-file";
      args = [
        "scheme=CRYPT"
        "${config.sops.secrets."mail-password".path}"
      ];
    };
    mailGroups = [ group ];
    extraConfig = ''
      mail_location = maildir:~/Maildir
      namespace inbox {
        inbox = yes
      }
      protocol imap {
        mail_max_userip_connections = 10
      }
    '';
  };

  services.rspamd = {
    enable = true;
    localOnly = false;
    services = [
      "proxy"
      "normal"
    ];
    dkim = {
      enable = true;
      path = "/var/lib/${dataDir}/dkim";
      selector = "mail";
      keys."${domain}" = {
        path = "/var/lib/${dataDir}/dkim/${domain}.mail.key";
        type = "rsa";
        bits = 2048;
      };
    };
    settings = {
      "subject" = "*** SPAM ***";
      "add_header" = 6;
      "reject_score" = 15;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/${dataDir} 0750 ${user} ${group} - -"
    "d /var/lib/${dataDir}/dkim 0750 ${user} ${group} - -"
    "d /var/lib/postfix 0755 postfix ${group} - -"
  ];

  systemd.services.rspamd = {
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };

  networking.firewall.allowedTCPPorts = [
    993 # IMAPS
    587 # SMTP submission from oak
  ];

  security.acme.certs."mail.${domain}" = {
    domain = "mail.${domain}";
    dnsProvider = vars.acmeDnsProvider;
    group = "nginx";
    environmentFile = config.sops.secrets."cloudflare_api_key".path;
  };
}
