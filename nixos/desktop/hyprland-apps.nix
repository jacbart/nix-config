{ pkgs, ... }: {
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    dunst
    eww
    hyprlock
    hypridle
    kitty
    libnotify
    rofi-wayland
  ];
}
