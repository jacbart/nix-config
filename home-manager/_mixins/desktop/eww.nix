{ config, pkgs, ... }: let 
    ewwconfig = builtins.fetchGit {
        url = "https://github.com/owenrumney/eww-bar";
        rev = "594295d5c0203c1c067a7c8004cf1d6fe835234b";
    };
in {
    home.packages = with pkgs; [
        eww
    ];
    
    # home.file."${config.xdg.configHome}/eww".source = ./eww;
    home.file."${config.xdg.configHome}/eww".source = ewwconfig;
}