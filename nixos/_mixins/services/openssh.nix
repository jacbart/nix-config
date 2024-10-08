{ lib, ... }: {
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkDefault "no";
      };
    };
    sshguard = {
      enable = true;
      # whitelist = [
      # ];
    };
  };
  programs.ssh.startAgent = lib.mkDefault true;
  networking.firewall.allowedTCPPorts = [ 22 ];
}
