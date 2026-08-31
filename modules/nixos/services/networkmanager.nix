{ pkgs, ... }:
{
  networking = {
    networkmanager = {
      enable = true;
      # No hardcoded nameservers: resolution goes through systemd-resolved
      # (see services/dns.nix) with strict DNS-over-TLS upstream.
      wifi = {
        backend = "iwd";
        powersave = false;
      };
    };
    wireless.iwd.package = pkgs.unstable.iwd;
  };
  # Workaround https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
}
