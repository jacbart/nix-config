{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    tailscale
    moonlight-qt
  ];
  text = builtins.readFile ./${name}.sh;
}
