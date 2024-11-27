{ config
, lib
, ...
}: {
  imports = [ ../../shell/zsh.nix ];
  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
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
