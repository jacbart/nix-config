{ pkgs }:
let
  waScript = pkgs.writeText "wa.py" (builtins.readFile ./wa.py);
in
pkgs.writeShellApplication {
  name = "wa";
  runtimeInputs = with pkgs; [
    python3
    woxi
    unstable.llama-cpp
  ];
  text = ''
    exec python3 ${waScript} "$@"
  '';
}
