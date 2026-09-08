# Avahi (mDNS) is enabled by the Sunshine module and publishes cork's service
# on every interface (lo, docker0, tailscale0, virbr0, ...). Moonlight clients
# resolve cork.local to whatever address avahi returns first — often an
# unreachable one (172.17.0.1 / 127.0.0.1) — so the host appears briefly then
# disappears. Restrict avahi to the real wired NIC.
{ ... }:
{
  services.avahi = {
    denyInterfaces = [
      "lo"
      "docker0"
      "tailscale0"
      "virbr0"
    ];
    # Sunshine only listens on IPv4, but cork has a global IPv6 address that
    # avahi otherwise advertises — Moonlight resolves cork.local to that IPv6
    # address and gets connection refused. Advertise IPv4 only.
    ipv6 = false;
  };
}
