{ config, pkgs, ... }: {
  imports = [
    ./firefox.nix
    ../services/nextcloud-client.nix
  ];

  home = {
    packages = with pkgs; [
      unstable.bitwarden-desktop
      unstable.element-desktop
      unstable.libreoffice-qt6-fresh # office document viewer
      unstable.geeqie # image veiwer
      vlc # multi-media viewer
    ];

    file."${config.xdg.dataHome}/images/moose-orange-bg.jpg".source = ./moose-orange-bg.jpg;
  };
}