{
  config,
  inputs,
  lib,
  pkgs,
  vars,
  ...
}:
{
  nixosHosts.mesquite = {
    modules = [
      config.flake.modules.nixos.core
      ../../nixos/hardware/fw4b0.nix
      ../../nixos/services/tailscale.nix
      ../../nixos/services/fail2ban.nix
    ]
    ++ [
      {
        # ── Kernel sysctl tuning for router workload ──────────────────────────
        boot.kernel.sysctl = {
          # ── Conntrack ──
          "net.netfilter.nf_conntrack_max" = 131072;
          "net.netfilter.nf_conntrack_tcp_timeout_established" = 54000;
          "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = 60;
          "net.netfilter.nf_conntrack_tcp_timeout_close_wait" = 30;
          "net.netfilter.nf_conntrack_tcp_timeout_fin_wait" = 30;
          "net.netfilter.nf_conntrack_udp_timeout" = 30;
          "net.netfilter.nf_conntrack_udp_timeout_stream" = 60;
          "net.netfilter.nf_conntrack_icmp_timeout" = 10;
          "net.netfilter.nf_conntrack_generic_timeout" = 120;

          # ── Network buffer sizes ──
          "net.core.rmem_max" = 16777216;
          "net.core.wmem_max" = 16777216;
          "net.core.rmem_default" = 1048576;
          "net.core.wmem_default" = 1048576;
          "net.ipv4.tcp_rmem" = "4096 1048576 16777216";
          "net.ipv4.tcp_wmem" = "4096 1048576 16777216";

          # ── Backlog / packet processing ──
          "net.core.netdev_max_backlog" = 8192;
          "net.core.netdev_budget" = 600;
          "net.core.netdev_budget_usecs" = 8000;
          "net.ipv4.tcp_max_syn_backlog" = 8192;
          "net.core.somaxconn" = 8192;

          # ── Congestion control ──
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.core.default_qdisc" = "fq_codel";
          "net.ipv4.tcp_slow_start_after_idle" = 0;
          "net.ipv4.tcp_fin_timeout" = 15;

          # ── TCP hardening ──
          "net.ipv4.tcp_syncookies" = 1;
          "net.ipv4.conf.all.rp_filter" = 1;
          "net.ipv4.conf.default.rp_filter" = 1;
          "net.ipv4.conf.all.accept_redirects" = 0;
          "net.ipv4.conf.all.send_redirects" = 0;
          "net.ipv4.conf.default.accept_redirects" = 0;
          "net.ipv6.conf.all.accept_redirects" = 0;
          "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
          "net.ipv4.conf.all.log_martians" = 1;

          # ── IPv6: disable auto-config (we configure explicitly) ──
          "net.ipv6.conf.all.accept_ra" = 0;
          "net.ipv6.conf.all.autoconf" = 0;
          "net.ipv6.conf.all.use_tempaddr" = 0;
        };

        # ── Swap (zram for low-memory appliance) ──────────────────────────────
        zramSwap = {
          enable = true;
          priority = 100;
          memoryPercent = 50;
        };

        # ── Networking hosts ──────────────────────────────────────────────────
        networking = {
          hostId = "a1b2c3d4"; # Required for ZFS compatibility, harmless otherwise
          hosts = {
            "127.0.0.2" = [
              "mesquite"
              "mesquite.${vars.domain}"
            ];
          };
        };

        # ── IRQ affinity and RPS tuning ───────────────────────────────────────
        systemd.services.network-tuning = {
          description = "Network IRQ affinity and RPS tuning for i211 NICs";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          path = [ pkgs.gawk ];
          script = ''
            for iface in enp1s0 enp2s0 enp3s0 enp4s0; do
              # Pin NIC hardware IRQs to core 3 (bitmask 8)
              for irq in $(grep "$iface" /proc/interrupts | awk '{print $1}' | tr -d ':'); do
                echo 8 > /proc/irq/$irq/smp_affinity 2>/dev/null || true
              done
              # Distribute RPS across cores 0-2 (bitmask 7)
              for queue in /sys/class/net/$iface/queues/rx-*/rps_cpus; do
                [ -f "$queue" ] && echo 7 > "$queue" 2>/dev/null || true
              done
              # Set RPS flow count
              for flow in /sys/class/net/$iface/queues/rx-*/rps_flow_cnt; do
                [ -f "$flow" ] && echo 4096 > "$flow" 2>/dev/null || true
              done
            done
            # Global RPS flow entries
            if [ -f /proc/sys/net/core/rps_sock_flow_entries ]; then
              echo 16384 > /proc/sys/net/core/rps_sock_flow_entries
            fi
          '';
        };

        # ── Useful router/network tools ───────────────────────────────────────
        environment.systemPackages = with pkgs; [
          ethtool
          conntrack-tools
          tcpdump
          iperf3
          nftables
          dig
          mtr
          nmap
        ];

        # ── Nix build settings (constrained hardware) ────────────────────────
        nix.settings = {
          max-jobs = 2;
          cores = 4;
        };
      }
    ]
    ++ [
      (import ./disks.nix { })
      ./network.nix
      ./nftables.nix
    ];
  };
}
