{ lib, ... }: {
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = lib.mkDefault true;
        PermitRootLogin = lib.mkDefault "prohibit-password";
        UseDns = lib.mkDefault true;
        X11Forwarding = lib.mkDefault false;
      };
    };
    sshguard = {
      enable = true;
      whitelist = [
        "100.100.100.100/10"
      ];
    };
  };
  programs.ssh.startAgent = lib.mkDefault true;
}
