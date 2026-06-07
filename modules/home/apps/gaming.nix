{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mangohud
    protonup-qt # optional GE updates beyond nixpkgs pin
  ];

  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    gpu_stats
    fps
    frametime
    toggle_hud=Shift_R+F12
  '';
}
