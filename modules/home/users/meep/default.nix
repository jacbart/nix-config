{
  config,
  lib,
  ...
}:
{
  imports = [
    ../../apps/ghostty.nix
  ];

  # Prefer over anything else that might still set gpg’s SSH socket (old HM env, ordering).
  systemd.user.sessionVariables = {
    SSH_AUTH_SOCK = lib.mkForce "%t/ssh-agent";
  };

  # zsh sources hm-session-vars; duplicate so new shells always match the OpenSSH agent.
  home.sessionVariables = {
    SSH_AUTH_SOCK = lib.mkForce "$XDG_RUNTIME_DIR/ssh-agent";
  };

  services = {
    gpg-agent = {
      enable = true;
      # OpenSSH keys (~/.ssh/id_git) via gpg's ssh bridge often fail with
      # "agent refused operation"; NixOS ssh-agent + core systemd SSH_AUTH_SOCK works.
      enableSshSupport = false;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
  };
}
