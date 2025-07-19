{
  desktop,
  lib,
  username,
  ...
}:
{
  imports =
    [
      (./. + "/${desktop}.nix")
    ]
    ++ lib.optional (builtins.pathExists (
      ./. + "/../users/${username}/desktop.nix"
    )) ../users/${username}/desktop.nix;

  # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
  services.mpris-proxy.enable = true;
}
