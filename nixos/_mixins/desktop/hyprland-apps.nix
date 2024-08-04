{ pkgs, ... }: {
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    kitty
    wezterm
    waybar
    dunst
    libnotify
    rofi-wayland
  ];
}