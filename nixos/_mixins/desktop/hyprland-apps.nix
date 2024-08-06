{ pkgs, ... }: {
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    kitty
    waybar
    dunst
    libnotify
    rofi-wayland
  ];
}