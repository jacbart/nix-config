{
  pkgs,
  platform,
  inputs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (pkgs.stdenv) isDarwin;
in
{
  imports = [
    ./base.nix
    ../zsh.nix
    ../tools/starship.nix
    ../tools
    ../../apps/newsboat.nix
  ];

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
  ]
  ++ lib.optional isDarwin "/opt/homebrew/bin";

  programs.carapace = {
    enable = true;
    package = pkgs.unstable.carapace;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };

  home.packages =
    (with pkgs; [
      dua
      fswatch
      fern
      mdbook
      uv
      htmlq
      unstable.nh
      stu
      inputs.ff.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.jaws.packages.${pkgs.stdenv.hostPlatform.system}.default
    ])
    ++ lib.optional isLinux pkgs.unstable.tlrc
    ++ lib.optional (pkgs.stdenv.hostPlatform.system != "aarch64-linux") pkgs.fex-cli;

  home.file.".config/fern/themes".source = "${pkgs.fern}/share/fern/themes";

  programs.zsh.shellAliases.summarize = "summarize-commit";
}
