{ pkgs, ... }: {
  imports = [
    ../../shell/tools/helix.nix
  ];

  home.packages = [ pkgs.nushell ];
}
