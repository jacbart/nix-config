{ ... }:
{
  # Encrypted DNS for clients (anti-poisoning).
  #
  # systemd-resolved speaks strict DNS-over-TLS to public resolvers so an
  # on-path attacker (rogue Wi-Fi, MITM, ISP tampering) can neither snoop
  # nor spoof lookups. DNSSEC is validated where the upstream signs
  # (allow-downgrade keeps unsigned zones working).
  #
  # NOTE: strict mode (DNSOverTLS = true) ignores any DNS server without a
  # TLS hostname annotation (including DHCP-pushed ones) and breaks DNS on
  # networks blocking port 853. Relax to "opportunistic" if that hurts.
  #
  # Once mesquite is deployed, point this at its LAN IP instead — its
  # unbound already validates DNSSEC and does DoT upstream:
  #   DNS = [ "<mesquite-ip>" ]; DNSOverTLS = false;
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
        "9.9.9.9#dns.quad9.net"
        "149.112.112.112#dns.quad9.net"
      ];
      DNSOverTLS = true;
      DNSSEC = "allow-downgrade";
    };
  };

  # Time-sync must not depend on DNS. No-RTC hosts (RockPro64) boot with a
  # garbage clock; strict DoT needs a correct clock for TLS cert validation,
  # and timesyncd's default servers (nixos.pool.ntp.org) are hostnames that
  # need DNS to resolve — a bootstrap deadlock (no DNS until clock is right,
  # no clock until DNS works). Point timesyncd at NTP servers by IP so the
  # clock self-heals on boot.
  services.timesyncd.servers = [
    "162.159.200.1" # Cloudflare
    "162.159.200.123" # Cloudflare
    "216.239.35.0" # Google
    "216.239.35.4" # Google
  ];
}
