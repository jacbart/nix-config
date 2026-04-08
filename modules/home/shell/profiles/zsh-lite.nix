{
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
in
{
  imports = [
    ./lite.nix
    ../zsh.nix
    ../tools/starship.nix
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
  ]
  ++ lib.optional isDarwin "/opt/homebrew/bin";
}
