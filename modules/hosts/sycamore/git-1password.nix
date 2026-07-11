{ config, lib, ... }:
{
  programs.ssh.settings."github.com" = lib.mkForce {
    HostName = "github.com";
    User = "jacbart";
    IdentityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
  };

  programs.git = {
    settings = {
      user.signingkey = lib.mkForce "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUy+3vM6NVymroDWo3WtZxOhcx8TVyALWD9Cdolbi2T";
      gpg.ssh = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
      };
    };
  };

  home.file."${config.xdg.configHome}/git/allowed_signers".text = ''
    jacbart@gmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHUy+3vM6NVymroDWo3WtZxOhcx8TVyALWD9Cdolbi2T
  '';

  home.activation.link1PasswordAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${config.home.homeDirectory}/.1password
    ln -sf ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ${config.home.homeDirectory}/.1password/agent.sock
  '';

  xdg.configFile."gh/hosts.yml".enable = lib.mkForce false;
}
