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
  # The oak mail relay (postfix) submits inbound mail to this server on 587.
  # Resolved via public DNS at postfix start.
  oakHost = "oak.${domain}";
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
        "${oakHost}"
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
    settings = {
      dovecot_config_version = config.services.dovecot2.package.version;
      dovecot_storage_version = config.services.dovecot2.package.version;
      mail_uid = user;
      mail_gid = group;
      mail_home = "/var/lib/${dataDir}/%{user}";
      mail_driver = "maildir";
      mail_path = "~/Maildir";
      protocols = [ "imap" ];
      ssl_server_cert_file = "/var/lib/acme/certs/mail.${domain}/fullchain.pem";
      ssl_server_key_file = "/var/lib/acme/private/mail.${domain}/key.pem";
      "namespace inbox" = {
        inbox = true;
        separator = "/";
        mailbox = {
          All = {
            auto = "create";
            special_use = "\\All";
          };
          Sent = {
            auto = "create";
            special_use = "\\Sent";
          };
          Trash = {
            auto = "create";
            special_use = "\\Trash";
          };
          Junk = {
            auto = "create";
            special_use = "\\Junk";
          };
        };
      };
      "passdb passwd-file" = {
        passwd_file_path = config.sops.secrets."mail-password".path;
      };
      "protocol imap" = {
        mail_max_userip_connections = 10;
      };
    };
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
