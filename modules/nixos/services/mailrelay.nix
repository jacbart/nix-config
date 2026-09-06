# Oak MX edge (postfix relay on the DigitalOcean droplet, PTR = droplet name
# mail.meep.sh).
#
#   inbound:  internet -> oak:25 (relay_domains) -> transport [maple-ts]:25 -> maple
#   outbound: maple relays through [oak]:587 (mynetworks trust) -> internet
#
# Only mail for meep.sh rides the transport map to maple; everything else
# oak itself sends (DSNs/bounces to external senders) delivers directly.
{
  config,
  pkgs,
  vars,
  ...
}:
let
  inherit (vars) domain;
  mapleIp = vars.tailscaleIps.maple;
  # mail.meep.sh cert issued by acme-proxy.nix (already imported on oak).
  acmeDir = config.security.acme.certs."mail.${domain}".directory;
in
{
  environment.systemPackages = [ pkgs.postfix ];

  services.postfix = {
    enable = true;
    # :587 exists solely as maple's outbound relay port — trusted networks
    # only (maple is in mynetworks); no SASL backend on this host.
    enableSubmission = true;
    submissionOptions = {
      smtpd_sasl_auth_enable = "no";
      smtpd_client_restrictions = "permit_mynetworks, reject";
    };
    settings.main = {
      myhostname = "mail.${domain}";
      relay_domains = [ domain ];
      mynetworks = [
        "127.0.0.0/8"
        "[::1]/128"
        "${mapleIp}/32" # maple's outbound relay
      ];
      message_size_limit = 52428800;
      smtpd_tls_security_level = "may";
      smtpd_tls_chain_files = [
        "${acmeDir}/key.pem"
        "${acmeDir}/fullchain.pem"
      ];
    };
    # Compiled to hash:/etc/postfix/transport by the module: meep.sh mail
    # rides the Tailscale relay to maple; the default stays direct smtp.
    transport = ''
      ${domain} smtp:[${mapleIp}]:25
    '';
  };

  networking.firewall.allowedTCPPorts = [
    25 # MX: inbound mail from the internet
    587 # Trusted relay port for maple's outbound (mynetworks only)
  ];
}
