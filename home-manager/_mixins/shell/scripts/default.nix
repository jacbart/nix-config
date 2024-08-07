{ config, pkgs, ... }:
let
    inherit (pkgs.stdenv) isDarwin;
in
{
    home.file."${config.xdg.dataHome}/zsh/scripts/os" = {
        source = if isDarwin then ./macos else ./linux;
        recursive = true;
    };

    home.file."${config.xdg.dataHome}/zsh/scripts/misc" = {
        source = ./misc;
        recursive = true;
    };
}