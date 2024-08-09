{ config, pkgs, ... }: {
    # home = {
    #     # waybar
    #     file."${config.xdg.configHome}/waybar/config".text = builtins.readFile ./waybar/config.json;
    #     file."${config.xdg.configHome}/waybar/style.css".text = builtins.readFile ./waybar/style.css;
    # };
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = builtins.readFile ./waybar/config.json;
      style = builtins.readFile ./waybar/style.css;
    };
}