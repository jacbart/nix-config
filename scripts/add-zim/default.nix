{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    coreutils-full
    xh
    gum
    fzf
  ];
  text = builtins.readFile ./${name}.sh;
}
