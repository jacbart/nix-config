{ pkgs, ... }: {
  imports = [
    ./localsend.nix
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