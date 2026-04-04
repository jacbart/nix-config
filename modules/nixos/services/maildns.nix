{
  config,
  lib,
  vars,
  ...
}:
let
  inherit (vars) domain;
in
{
  options = {
    mailserver = {
      mxHost = lib.mkOption {
        type = lib.types.str;
        default = "mail.${domain}";
        description = "MX hostname";
      };
      dkimSelector = lib.mkOption {
        type = lib.types.str;
        default = "mail";
        description = "DKIM selector";
      };
    };
  };

  config = {
    environment.etc."mail-dns-records.txt" = {
      text = ''
        ============================================
        EMAIL DNS RECORDS FOR ${domain}
        ============================================

        These DNS records need to be configured in Cloudflare:

        1. MX RECORD
        ------------
        Name:    @
        Content: ${config.mailserver.mxHost}
        Priority: 10
        TTL:     Auto

        2. SPF RECORD
        -------------
        Name:    @
        Content: v=spf1 mx a:${config.mailserver.mxHost} ~all
        TTL:     Auto

        3. DMARC RECORD
        ---------------
        Name:    _dmarc
        Content: v=DMARC1; p=quarantine; rua=mailto:postmaster@${domain}; pct=100
        TTL:     Auto

        4. DKIM RECORD (after rspamd generates keys)
        --------------------------------------------
        After the first build, retrieve the DKIM public key from:
          /var/lib/mail/dkim/${domain}.mail.txt

        Then add a TXT record:
        Name:    ${config.mailserver.dkimSelector}._domainkey
        Content: <public key from rspamd>
        TTL:     Auto

        ============================================
      '';
      mode = "0444";
    };
  };
}
