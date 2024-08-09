{ config, pkgs, ... }: {
    home = {
        # waybar
        file."${config.xdg.configHome}/waybar/config.jsonc".text = builtins.readFile ./waybar/config.jsonc;
        file."${config.xdg.configHome}/waybar/style.css".text = builtins.readFile ./waybar/style.css;
    };
    home.packages = with pkgs; [
        waybar
    ];
}