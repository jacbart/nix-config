{ lib, ... }: {
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = lib.mkDefault true;
        PermitRootLogin = lib.mkDefault "no";
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
