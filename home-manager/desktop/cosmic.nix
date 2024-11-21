{ config, pkgs, ... }: {
  imports = [
    ../apps/firefox.nix
    # ../apps/rustdesk.nix
    ../apps/zed-editor.nix
    ../services/nextcloud-client.nix
  ];

  home = {
    packages = with pkgs; [
      bitwarden-desktop
      element-desktop
      # libreoffice-qt6-fresh # office document viewer
      geeqie # image veiwer
      wl-clipboard # wl-copy and wl-paste
      vlc # multi-media viewer
    ];
    file."${config.home.homeDirectory}/Pictures/wallpapers/bg.jpg".source = ../files/bg.jpg;
  };

}
