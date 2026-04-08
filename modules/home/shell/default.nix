{
  pkgs,
  platform,
  lib,
  inputs,
  shellProfile,
  ...
}:
# shellProfile: lite | zsh-lite | dev-heavy — see README.md (Shell / profiles).
{
  imports =
    if shellProfile == "lite" then
      [ ./profiles/lite.nix ]
    else if shellProfile == "dev-heavy" then
      [ ./profiles/dev-heavy.nix ]
    else
      [ ./profiles/zsh-lite.nix ];
}
