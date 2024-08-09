{ config, pkgs, ... }: {
    home = {
        # waybar
        file."${config.xdg.configHome}/waybar/config".text = builtins.readFile ./waybar/config.json;
        file."${config.xdg.configHome}/waybar/style.css".text = builtins.readFile ./waybar/style.css;
    };
    home.packages = with pkgs; [
        waybar
    ];
}