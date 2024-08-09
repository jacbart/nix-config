{ config, pkgs, ... }: {
    home.packages = with pkgs; [
        eww
    ];
    
    home.file."${config.xdg.configHome}/eww".source = ./eww;
}