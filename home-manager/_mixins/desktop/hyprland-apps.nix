{ pkgs, ... }: {
  imports = [
    ./localsend.nix
  ];

  home.packages = with pkgs; [
    kitty
    wezterm
    waybar
    dunst
    libnotify
    rofi-wayland
  ];
}