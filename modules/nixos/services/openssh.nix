{
  lib,
  config,
  vars,
  ...
}:
{
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = lib.mkDefault true;
        # PermitRootLogin = lib.mkDefault "prohibit-password";
        UseDns = lib.mkDefault true;
        X11Forwarding = lib.mkDefault false;
        KbdInteractiveAuthentication = lib.mkDefault true;
      };
    };
    # Disabled on hardened hosts — fail2ban subsumes sshguard's role there
    # (see modules/nixos/services/fail2ban.nix). Both watching the same logs
    # and fighting over iptables chains is messy.
    sshguard = {
      enable = !builtins.elem config.networking.hostName vars.hardenedHosts;
      whitelist = [
        "100.100.100.100/10"
      ];
    };
    gnome.gcr-ssh-agent.enable = lib.mkForce false;
  };
  programs.ssh.startAgent = lib.mkDefault true;
}
