{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    ripgrep
    fzf
    gawk
    coreutils
  ];
  text = builtins.readFile ./${name}.sh;
}
