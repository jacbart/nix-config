{ config, pkgs, ... }: let
    inherit (pkgs.stdenv) isDarwin;
in {
    home.file."${config.xdg.dataHome}/zsh/functions/os" = {
        source = if isDarwin then ./macos else ./linux;
        recursive = true;
    };

    home.file."${config.xdg.dataHome}/zsh/functions/misc" = {
        source = ./misc;
        recursive = true;
    };
}