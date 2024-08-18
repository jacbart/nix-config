{ pkgs, ... }: 
let
    name = builtins.baseNameOf (builtins.toString ./.);
    journalShellApp = pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = with pkgs; [
            coreutils-full
        ];
        text = builtins.readFile ./${name}.zsh;
    };
in {
    home.packages = with pkgs; [ journalShellApp ];
}