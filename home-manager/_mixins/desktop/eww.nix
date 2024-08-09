{ pkgs, ... }: {
    home.packages = with pkgs; [
        eww-wayland
    ];
    theme = builtins.fetchGit {
        url = "https://github.com/saimoomedits/eww-widgets/eww";
        rev = "cfb2523a4e37ed2979e964998d9a4c37232b2975";
    };
    home.file."${config.xdg.configHome}/eww".source = "${theme}/eww";
}