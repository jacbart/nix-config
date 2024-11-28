{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  name = "headplane";
  buildInputs = with pkgs; [
    figlet
    nodejs_23
    pnpm
  ];
  shellHook = ''
    figlet headplane
  '';
}
