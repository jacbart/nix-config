{ config, pkgs, ... }: {
    home = {
        # waybar
        file."${config.xdg.configHome}/waybar/config".text = builtins.readFile ./waybar/config;
        file."${config.xdg.configHome}/waybar/style.css".text = builtins.readFile ./waybar/style.css;
    };
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
    };
}