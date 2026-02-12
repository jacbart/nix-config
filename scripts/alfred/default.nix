{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    llama-cpp
    coreutils
    findutils
    gnugrep
    procps
  ];
  text = builtins.readFile ./${name}.zsh;
}
