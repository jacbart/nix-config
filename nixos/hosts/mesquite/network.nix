{
  lib,
  ...
}:
{
  # ── Interface configuration ───────────────────────────────────────────
  networking = {
    useDHCP = false;

    # WAN: DHCP from ISP
    interfaces.enp1s0.useDHCP = true;

    # LAN bridge: static IP as gateway
    bridges.br-lan = {
      interfaces = [
        "enp2s0"
        "enp3s0"
        "enp4s0"
      ];
    };

    interfaces.br-lan = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.120.0.1";
          prefixLength = 24;
        }
      ];
    };

    # Don't use NetworkManager on a router
    networkmanager.enable = lib.mkForce false;
  };

  # ── Kea DHCPv4 server ────────────────────────────────────────────────
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = {
        interfaces = [ "br-lan" ];
      };

      lease-database = {
        type = "memfile";
        persist = true;
        name = "/var/lib/kea/dhcp4-leases.csv";
        lfc-interval = 3600;
      };

      valid-lifetime = 3600;
      renew-timer = 900;
      rebind-timer = 1800;

      subnet4 = [
        {
          id = 1;
          subnet = "10.120.0.0/24";
          pools = [
            {
              pool = "10.120.0.100 - 10.120.0.254";
            }
          ];
          option-data = [
            {
              name = "routers";
              data = "10.120.0.1";
            }
            {
              name = "domain-name-servers";
              data = "10.120.0.1";
            }
            {
              name = "domain-name";
              data = "lan.meep.sh";
            }
          ];
        }
      ];
    };
  };

  # ── Unbound recursive DNS resolver ───────────────────────────────────
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [
          "10.120.0.1"
          "127.0.0.1"
          "::1"
        ];

        access-control = [
          "10.120.0.0/24 allow"
          "127.0.0.0/8 allow"
          "::1/128 allow"
        ];

        # Performance
        num-threads = 4;
        msg-cache-slabs = 4;
        rrset-cache-slabs = 4;
        infra-cache-slabs = 4;
        key-cache-slabs = 4;
        msg-cache-size = "64m";
        rrset-cache-size = "128m";

        # Privacy and security
        hide-identity = true;
        hide-version = true;
        harden-glue = true;
        harden-dnssec-stripped = true;
        use-caps-for-id = true;
        val-clean-additional = true;

        # Performance: prefetch popular entries before TTL expires
        prefetch = true;
        prefetch-key = true;
        serve-expired = true;

        # Logging
        verbosity = 1;
        log-queries = false;
      };

      # Forward to upstream resolvers instead of full recursion
      # (lower latency for a home network)
      forward-zone = [
        {
          name = ".";
          forward-addr = [
            "1.1.1.1@853#cloudflare-dns.com" # Cloudflare DoT
            "1.0.0.1@853#cloudflare-dns.com"
            "9.9.9.9@853#dns.quad9.net" # Quad9 DoT
            "149.112.112.112@853#dns.quad9.net"
          ];
          forward-tls-upstream = true;
        }
      ];
    };
  };

  # Ensure resolved doesn't conflict with unbound
  services.resolved.enable = false;
}
