{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    openssh
    git
    gum
  ];
  text = builtins.readFile ./${name}.sh;
  checkPhase = "";
}
