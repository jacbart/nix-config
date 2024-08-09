{ config, pkgs, ... }: {
    # home = {
    #     # waybar
    #     file."${config.xdg.configHome}/waybar/config".text = builtins.readFile ./waybar/config.json;
    #     file."${config.xdg.configHome}/waybar/style.css".text = builtins.readFile ./waybar/style.css;
    # };
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = builtins.fromJSON (builtins.readFile ./waybar/config.json);
      style = builtins.fromJSON (builtins.readFile ./waybar/style.css);
    };
}