{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = [
    pkgs.coreutils-full
    pkgs.git
    pkgs.gum
    pkgs.jq
    pkgs.e2fsprogs
  ];
  text = builtins.readFile ./${name}.sh;
}
