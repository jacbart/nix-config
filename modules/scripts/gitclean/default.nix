{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    gnused
    gnugrep
    gitMinimal
    findutils
  ];
  text = builtins.readFile ./${name}.sh;
}
