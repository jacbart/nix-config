{ lib, ... }:
{
  # Disable the default NixOS iptables-based firewall and NAT.
  # We replace it entirely with nftables for better performance.
  networking = {
    firewall.enable = lib.mkForce false;
    nat.enable = false;
    nftables.enable = true;
  };

  networking.nftables.ruleset = ''
    table inet filter {
      # Flow offloading: bypass the full netfilter stack for established
      # TCP/UDP connections. This is critical for the J3160's limited CPU
      # to achieve near wire-speed forwarding on 1GbE.
      flowtable f {
        hook ingress priority 0;
        devices = { enp1s0, br-lan };
      }

      chain input {
        type filter hook input priority filter; policy drop;

        # Loopback
        iifname "lo" accept

        # Trust LAN
        iifname "br-lan" accept

        # Established/related from WAN
        iifname "enp1s0" ct state established,related accept

        # ICMP (ping) from WAN — rate limited
        iifname "enp1s0" icmp type echo-request limit rate 5/second accept

        # SSH from WAN — rate limited for brute force protection
        iifname "enp1s0" tcp dport 22 ct state new limit rate 3/minute accept

        # Tailscale (WireGuard UDP) from WAN
        iifname "enp1s0" udp dport 41641 accept

        # DHCP server responses (on LAN bridge)
        udp dport 67 accept

        # DNS (served by unbound on LAN)
        iifname "br-lan" tcp dport 53 accept
        iifname "br-lan" udp dport 53 accept

        # Log and drop everything else
        counter log prefix "nft-input-drop: " drop
      }

      chain forward {
        type filter hook forward priority filter; policy drop;

        # Flow offload established TCP/UDP for performance
        ip protocol { tcp, udp } flow offload @f

        # Allow LAN -> WAN (outbound)
        iifname "br-lan" oifname "enp1s0" accept

        # Allow WAN -> LAN only for established/related (return traffic)
        iifname "enp1s0" oifname "br-lan" ct state established,related accept

        # Log and drop everything else
        counter log prefix "nft-forward-drop: " drop
      }
    }

    table ip nat {
      chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;

        # Masquerade LAN traffic going out the WAN interface
        oifname "enp1s0" masquerade
      }
    }
  '';
}
