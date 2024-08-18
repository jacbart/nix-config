{ pkgs, ... }: 
let
    inherit (pkgs.stdenv) isLinux;
    name = builtins.baseNameOf (builtins.toString ./.);
    brightnessShellApp = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
            coreutils-full
            bc # calulator
        ];
        text = builtins.readFile ./${name}.zsh;
    };
in {
    home.packages = with pkgs; lib.optional isLinux brightnessShellApp;
}