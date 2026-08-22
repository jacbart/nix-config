# wayvnc: VNC server for wlroots-based Wayland compositors (niri).
#
# Binds exclusively to the tailscale0 interface IP so the VNC server is
# reachable only over Tailscale — no LAN/WAN exposure. Auth is PAM (the
# user's Unix login credentials); no password file to manage. The NixOS
# module (programs.wayvnc.enable) installs the package + PAM service;
# this home-manager module runs wayvnc as a user-level systemd service
# within the Wayland session.
{ pkgs, ... }:
let
  # Resolve the tailscale0 IPv4 address at service startup, retrying
  # until Tailscale is up (the service may start before tailscaled has
  # assigned an IP on boot). Then exec wayvnc bound to that address.
  startWayvnc = pkgs.writeShellScript "wayvnc-start" ''
    set -eu
    ts_ip=""
    for _ in $(seq 1 30); do
      ts_ip=$(${pkgs.iproute2}/bin/ip -4 -o addr show tailscale0 2>/dev/null \
        | ${pkgs.gawk}/bin/awk '{print $4}' | ${pkgs.coreutils}/bin/cut -d/ -f1 || true)
      [ -n "$ts_ip" ] && break
      sleep 2
    done
    if [ -z "$ts_ip" ]; then
      echo "wayvnc: no tailscale0 IPv4 address after 60s; is Tailscale up?" >&2
      exit 1
    fi
    exec ${pkgs.wayvnc}/bin/wayvnc "$ts_ip" 5900
  '';
in
{
  systemd.user.services.wayvnc = {
    Unit = {
      Description = "VNC server (wayvnc) bound to tailscale0";
      After = [
        "graphical-session.target"
        "tailscaled.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = startWayvnc;
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
