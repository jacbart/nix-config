{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = [
    pkgs.coreutils-full
  ];
  text = builtins.readFile ./${name}.sh;
}
