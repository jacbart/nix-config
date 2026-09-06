# Maple mailbox stack: postfix (virtual mailboxes) + dovecot (IMAPS/LMTP) +
# rspamd (milter/DKIM).
#
# Mail flow:
#   inbound:  internet -> oak:25 (MX edge) -> [maple-ts]:25 (trusted) -> rspamd -> LMTP -> Maildir
#   outbound: MUA/aerc -> maple:587 (SASL, TLS, ORIGINATING -> DKIM sign) or local
#             -> relayhost [oak-ts]:587 -> internet
#
# Inbound rides the smtp (25) service on purpose: the submission port sets
# the ORIGINATING milter macro, which would make rspamd DKIM-sign relayed
# foreign mail with our domain key.
#
# `meep.sh` is a VIRTUAL mailbox domain (never in mydestination): recipients
# resolve via virtual_alias_maps into the `jack` mailbox, delivered by
# dovecot LMTP under /var/lib/mail/jack/Maildir. Authentication for both
# IMAPS (993) and submission (587) comes from the sops-managed dovecot
# passwd-file (`mail-password` in nix-secrets):
#   jack:{ARGON2}<hash>
# generated with: doveadm pw -s ARGON2ID
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
  # oak relays inbound mail to us and accepts our outbound relay, over Tailscale.
  oakIp = vars.tailscaleIps.oak; # trusted on :25 (see mynetworks)
  # Wildcard *.meep.sh cert issued by acme-base.nix; dovecot and postfix
  # share it (no separate mail cert on maple).
  acmeDir = config.security.acme.certs."${domain}".directory;
  # nixpkgs postfix queue_directory — dovecot sockets that postfix consumes
  # must live inside it (postfix refers to them relative to its chroot).
  postfixQueue = "/var/lib/postfix/queue";
in
{
  users.users."${user}" = {
    isSystemUser = true;
    inherit group;
    home = "/var/lib/${dataDir}";
  };

  users.groups."${group}" = { };

  sops.secrets."mail-password" = {
    # dovecot's auth process (runs as dovecot2) reads the passdb file; it
    # must be group-readable rather than owned by vmail.
    group = "dovecot2";
    mode = "0440";
  };

  environment.systemPackages = with pkgs; [
    dovecot # doveadm (passwd-file hash generation)
    postfix # postconf / postqueue
    rspamd # rspamadm (dkim_keygen)
  ];

  services.postfix = {
    enable = true;
    # MUA submission (aerc etc.): module defaults enforce TLS + SASL; we only
    # point SASL at dovecot's auth socket.
    enableSubmission = true;
    submissionOptions = {
      smtpd_sasl_auth_enable = "yes";
      smtpd_sasl_type = "dovecot";
      smtpd_sasl_path = "private/auth";
    };
    settings.main = {
      # Distinct from oak's mail.<domain> (the public MX): postfix's loop
      # detection bounces oak->maple relay when both greet with the same
      # hostname. maple only talks SMTP over Tailscale, so its own name is
      # fine (the wildcard *.meep.sh cert still covers it for TLS).
      myhostname = "maple.${domain}";
      mydomain = domain;
      # meep.sh is delivered via LMTP (virtual), not to system users.
      mydestination = [ "localhost" ];
      virtual_mailbox_domains = [ domain ];
      virtual_transport = "lmtp:unix:private/dovecot-lmtp";
      mynetworks = [
        "127.0.0.0/8"
        "[::1]/128"
        "${oakIp}/32" # inbound relay from oak
      ];
      # All remote outbound mail rides oak's clean IP + PTR. Virtual/local
      # delivery never consults relayhost.
      relayhost = [ "[${oakIp}]:587" ];
      message_size_limit = 52428800;
      smtpd_tls_security_level = "may";
      smtpd_tls_chain_files = [
        "${acmeDir}/key.pem"
        "${acmeDir}/fullchain.pem"
      ];
    };
    # Role addresses + catchall into the single mailbox (compiled to
    # hash:/etc/postfix/virtual by the module).
    virtual = ''
      postmaster@${domain} jack@${domain}
      root@${domain} jack@${domain}
      abuse@${domain} jack@${domain}
      @${domain} jack@${domain}
    '';
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
      protocols = [
        "imap"
        "lmtp"
      ];
      # Wildcard cert (see acmeDir above)
      ssl_server_cert_file = "${acmeDir}/fullchain.pem";
      ssl_server_key_file = "${acmeDir}/key.pem";
      "namespace inbox" = {
        inbox = true;
        separator = "/";
      };
      # Dovecot 2.4 wants named mailbox sections *inside* the namespace,
      # rendered as `mailbox Sent { ... }` — a flat key with the name after
      # the section keyword (same shape as `passdb passwd-file`), not a
      # nested `mailbox.Sent` attrset (which yields an invalid `mailbox { }`).
      "namespace inbox"."mailbox All" = {
        auto = "create";
        special_use = "\\All";
      };
      "namespace inbox"."mailbox Sent" = {
        auto = "create";
        special_use = "\\Sent";
      };
      "namespace inbox"."mailbox Trash" = {
        auto = "create";
        special_use = "\\Trash";
      };
      "namespace inbox"."mailbox Junk" = {
        auto = "create";
        special_use = "\\Junk";
      };
      # LMTP/SASL look up `jack@meep.sh`, but the passwd-file key is the bare
      # local part `jack`. Strip the domain for lookups (dovecot 2.4 renamed
      # 2.3's %n to %{user | username}).
      auth_username_format = "%{user | username}";
      "passdb passwd-file" = {
        passwd_file_path = config.sops.secrets."mail-password".path;
      };
      # Delivery identity for LMTP: every mailbox lives under vmail. Dovecot
      # 2.4 wants the compact section name plus a structured fields block
      # (verified against doveconf 2.4.5; a bare `userdb { args = ... }` is
      # rejected).
      "userdb static" = {
        fields = {
          uid = user;
          gid = group;
          home = "/var/lib/${dataDir}/%{user}";
        };
      };
      "protocol imap" = {
        mail_max_userip_connections = 10;
      };
      # LMTP socket for postfix virtual_transport (inside postfix's queue
      # dir so the chrooted lmtp client can reach it).
      "service lmtp" = {
        "unix_listener ${postfixQueue}/private/dovecot-lmtp" = {
          mode = "0660";
          user = "postfix";
          group = "postfix";
        };
      };
      # SASL auth socket for postfix submission (smtpd_sasl_path private/auth).
      "service auth" = {
        "unix_listener ${postfixQueue}/private/auth" = {
          mode = "0660";
          user = "postfix";
          group = "postfix";
        };
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
      # Path template must match mail-dkim-keygen's output:
      # /var/lib/mail/dkim/meep.sh_mail.key
      "dkim_signing.conf".text = ''
        selector = "mail";
        domain = "${domain}";
        path = "/var/lib/${dataDir}/dkim/$domain_$selector.key";
      '';
    };
    postfix.enable = true;
  };

  # Generate the DKIM keypair once (rspamd signs with the private key; the
  # public TXT record goes into vars.dns.records.mail._domainkey).
  systemd.services.mail-dkim-keygen = {
    description = "Generate the rspamd DKIM keypair for ${domain} (once)";
    wantedBy = [ "multi-user.target" ];
    before = [ "rspamd.service" ];
    after = [ "systemd-tmpfiles-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      keyDir="/var/lib/${dataDir}/dkim"
      key="$keyDir/${domain}_mail.key"
      if [ ! -s "$key" ]; then
        mkdir -p "$keyDir"
        # stdout is the public TXT record — publish it in Cloudflare via
        # vars.dns.records.mail._domainkey, then `task dns:apply`.
        ${pkgs.rspamd}/bin/rspamadm dkim_keygen \
          -b 2048 -d "${domain}" -s mail -k "$key" \
          > "$keyDir/${domain}.mail.txt"
      fi
      chown "${user}:rspamd" "$keyDir" "$key" "$keyDir/${domain}.mail.txt" 2>/dev/null || true
      chmod 0750 "$keyDir"
      chmod 0640 "$key" "$keyDir/${domain}.mail.txt" 2>/dev/null || true
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/${dataDir} 0750 ${user} ${group} - -"
    # rspamd (running as its own user) reads the DKIM key from here.
    "d /var/lib/${dataDir}/dkim 0750 ${user} rspamd - -"
    "d /var/lib/postfix 0755 postfix ${group} - -"
  ];

  # Dovecot/postfix read the ACME wildcard directly; wait for issuance
  # instead of racing it at boot.
  systemd.services.dovecot = {
    after = [ "acme-${domain}.service" ];
    wants = [ "acme-${domain}.service" ];
  };
  systemd.services.postfix = {
    after = [ "acme-${domain}.service" ];
    wants = [ "acme-${domain}.service" ];
  };

  networking.firewall.allowedTCPPorts = [
    25 # SMTP: oak's inbound relay over Tailscale (rspamd scans as inbound)
    993 # IMAPS (Tailscale clients)
    587 # SMTP submission (SASL MUAs; ORIGINATING -> DKIM sign)
  ];
}
