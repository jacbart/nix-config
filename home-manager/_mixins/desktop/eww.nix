{ config, pkgs, ... }: {
    home.packages = with pkgs; [
        eww
    ];

    services.playerctld = {
        enable = true;
        package = pkgs.playerctl;
    };
    
    home.file."${config.xdg.configHome}/eww".source = ./eww;
}
