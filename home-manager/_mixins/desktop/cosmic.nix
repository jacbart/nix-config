{ config, pkgs, ... }: {
  imports = [
    ./firefox.nix
    ./rustdesk.nix
    ../services/nextcloud-client.nix
  ];

  home = {
    packages = with pkgs; [
      # unstable.ladybird
      unstable.bitwarden-desktop
      unstable.element-desktop
      unstable.libreoffice-qt6-fresh # office document viewer
      unstable.geeqie # image veiwer
      unstable.wl-clipboard # wl-copy and wl-paste
      gparted
      vlc # multi-media viewer
    ];
    file."${config.home.homeDirectory}/Pictures/wallpapers/bg.jpg".source = ./bg.jpg;
  };

}
