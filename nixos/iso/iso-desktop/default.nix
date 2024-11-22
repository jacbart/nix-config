{ lib, ... }: {
  imports = [
    # ../../services/bluetooth.nix
    ../../services/pipewire.nix
    ../../services/openssh.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
