# Mirrors modules/nixos/desktop/default.nix: pick HM desktop modules from extraSpecialArgs.desktop.
{ desktop, lib, ... }:
{
  imports =
    if desktop == null then
      [ ]
    else
      lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix;
}
