{ config, pkgs, ... }: let
    eww-config = builtins.fetchGit {
        url = "https://github.com/saimoomedits/eww-widgets";
        rev = "cfb2523a4e37ed2979e964998d9a4c37232b2975";
    };
in {
    home.packages = with pkgs; [
        eww
    ];
    
    home.file."${config.xdg.configHome}/eww".source = "${eww-config}/eww/bar";
}