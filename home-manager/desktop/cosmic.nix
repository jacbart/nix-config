{ config
, pkgs
, ...
}: {
  imports = [
    # ../apps/firefox.nix
    # ../apps/rustdesk.nix
    ../apps/lan-mouse.nix # virtual kvm
    ../apps/zed-editor.nix
    ../services/nextcloud-client.nix
  ];

  home = {
    packages = with pkgs; [
      unstable.bitwarden-desktop
      unstable.element-desktop
      # libreoffice-qt6-fresh # office document viewer
      geeqie # image veiwer
      # helvum # GTK patchbay for pipewire
      # unstable.freetube # youtube
      # unstable.pipeline # peertube - peer to peer video
      wl-clipboard # wl-copy and wl-paste
      vlc # multi-media viewer
      unstable.librewolf

      gimp-with-plugins
      unstable.zoom-us
      unstable.discord
      unstable.slack
    ];
    file."${config.home.homeDirectory}/Pictures/wallpapers/bg.jpg".source = ../files/bg.jpg;
  };
}
