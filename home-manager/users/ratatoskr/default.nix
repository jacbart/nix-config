{ pkgs
, ... }: {
  imports = [
    ../../shell/nushell.nix
    ../../shell/tools/helix.nix
  ];

  home.packages = [ pkgs.nushell ];
}
