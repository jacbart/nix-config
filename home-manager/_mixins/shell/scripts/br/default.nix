{ pkgs, ... }: 
let
    name = builtins.baseNameOf (builtins.toString ./.);
    brShellApp = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
            coreutils-full
            broot
        ];
        text = builtins.readFile ./${name}.zsh;
    };
in {
    home.packages = with pkgs; [ brShellApp ];
}