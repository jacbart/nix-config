{
  pkgs,
  platform,
  lib,
  inputs,
  shellProfile,
  ...
}:
{
  imports =
    if shellProfile == "lite" then
      [ ./profiles/lite.nix ]
    else if shellProfile == "dev-heavy" then
      [ ./profiles/dev-heavy.nix ]
    else
      [ ./profiles/zsh-lite.nix ];
}
