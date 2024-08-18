{ pkgs, lib, ... }: 
let
    inherit (pkgs.stdenv) isLinux;
    name = builtins.baseNameOf (builtins.toString ./.);
    volumeShellApp = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
            coreutils-full
            bc # calulator
        ];
        text = builtins.readFile ./${name}.zsh;
    };
in {
    home.packages = with pkgs; lib.optional isLinux volumeShellApp;
}