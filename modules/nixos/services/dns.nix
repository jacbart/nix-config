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
}
