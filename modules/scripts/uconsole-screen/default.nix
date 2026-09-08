{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    brightnessctl
    coreutils
  ];
  text = builtins.readFile ./${name}.sh;
}
