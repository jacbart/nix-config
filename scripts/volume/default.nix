{ pkgs, ... }: 
let
    name = builtins.baseNameOf (builtins.toString ./.);
in pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
        coreutils-full
        bc # calulator
    ];
    text = builtins.readFile ./${name}.zsh;
}