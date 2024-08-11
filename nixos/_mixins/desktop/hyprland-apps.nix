{ pkgs, ... }: {
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    hyprlock
    hypridle
    kitty
    waybar
    dunst
    libnotify
    rofi-wayland
  ];
}
