{ pkgs, ... }: {
  imports = [
    ./rofi.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      alacritty
      alacritty-theme
      # blueman
      elementary-xfce-icon-theme
      font-manager
      libqalculate
      pavucontrol
      wmctrl
      xclip
      xcolor
      xdo
      xdotool
      xfce.xfce4-appfinder
      xfce.xfce4-clipman-plugin
      xfce.xfce4-dict
      xfce.xfce4-fsguard-plugin
      xfce.xfce4-genmon-plugin
      xfce.xfce4-netload-plugin
      xfce.xfce4-panel
      xfce.xfce4-pulseaudio-plugin
      xfce.xfce4-systemload-plugin
      xfce.xfce4-whiskermenu-plugin
      xfce.xfce4-xkb-plugin
      xorg.xev
      xsel
      xtitle
      xwinmosaic
      zuki-themes
    ];
  };
}
