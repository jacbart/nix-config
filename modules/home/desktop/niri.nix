{
  pkgs,
  ...
}:
{
  imports = [
    ../apps/rustdesk.nix
    ../apps/zed-editor.nix
    # ../apps/lan-mouse.nix # virtual kvm
    ./personal-services.nix
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

  programs.waybar.settings.mainBar = {
    layer = "top";
    position = "top";
    height = 30;
    output = [
      "eDP-1"
      "HDMI-A-1"
    ];
    modules-left = [
      "sway/workspaces"
      "sway/mode"
      "wlr/taskbar"
    ];
    modules-center = [
      "sway/window"
      "custom/hello-from-waybar"
    ];
    modules-right = [
      "mpd"
      "custom/mymodule#with-css-id"
      "temperature"
    ];

    "sway/workspaces" = {
      disable-scroll = true;
      all-outputs = true;
    };
    "custom/hello-from-waybar" = {
      format = "hello {}";
      max-length = 40;
      interval = "once";
      exec = pkgs.writeShellScript "hello-from-waybar" ''
        echo "from within waybar"
      '';
    };
  };
}
