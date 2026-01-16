{
  pkgs,
  ...
}:
{
  imports = [
    ../apps/rustdesk.nix
    ../apps/zed-editor.nix
    # ../apps/lan-mouse.nix # virtual kvm
    ../services/nextcloud-client.nix
  ];

  home = {
    packages = with pkgs; [
      unstable.bitwarden-desktop
      unstable.element-desktop
      # libreoffice-qt6-fresh # office document viewer
      geeqie # image veiwer
      # helvum # GTK patchbay for pipewire
      # unstable.pipeline # peertube - peer to peer video
      wl-clipboard # wl-copy and wl-paste
      vlc # multi-media viewer
      unstable.librewolf
      unstable.vivaldi

      gimp-with-plugins
      unstable.zoom-us
      unstable.discord
      unstable.slack
    ];
  };
}
