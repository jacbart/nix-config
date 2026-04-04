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
  oakIp = "100.116.178.48";
in
{
  users.users."${user}" = {
    isSystemUser = true;
    inherit group;
    home = "/var/lib/${dataDir}";
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

  services.postfix = {
    enable = true;
    settings.main = {
      myhostname = "mail.${domain}";
      mydomain = domain;
      mydestination = [
        domain
        "localhost"
      ];
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
    enablePAM = false;
    createMailUser = true;
    mailUser = user;
    mailGroup = group;
    mailLocation = "maildir:~/Maildir";
    mailboxes = {
      All = {
        auto = "create";
        specialUse = "All";
      };
      Sent = {
        auto = "create";
        specialUse = "Sent";
      };
      Trash = {
        auto = "create";
        specialUse = "Trash";
      };
      Junk = {
        auto = "create";
        specialUse = "Junk";
      };
    };
    sslServerCert = "/var/lib/acme/certs/mail.${domain}/fullchain.pem";
    sslServerKey = "/var/lib/acme/private/mail.${domain}/key.pem";
    extraConfig = ''
      auth_mechanisms = plain login
      passdb {
        driver = passwd-file
        args = scheme=CRYPT ${config.sops.secrets."mail-password".path}
      }
      userdb {
        driver = static
        args = uid=vmail gid=vmail home=/var/lib/mail/%u
      }
      protocol imap {
        mail_max_userip_connections = 10
      }
    '';
  };

  services.rspamd = {
    enable = true;
    locals = {
      "options.inc".text = ''
        subject = "*** SPAM ***";
        add_header = 6;
        reject_score = 15;
      '';
      "dkim_signing.conf".text = ''
        selector = "mail";
        domain = "${domain}";
        path = "/var/lib/${dataDir}/dkim/$domain_$selector.key";
      '';
    };
    postfix.enable = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/${dataDir} 0750 ${user} ${group} - -"
    "d /var/lib/${dataDir}/dkim 0750 ${user} ${group} - -"
    "d /var/lib/postfix 0755 postfix ${group} - -"
  ];

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
