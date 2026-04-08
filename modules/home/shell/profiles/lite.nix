{
  pkgs,
  platform,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./base.nix
    ../tools/lite.nix
  ];
}
