{
  config,
  lib,
  ...
}:
{
  networking = {
    # hostId = "";
    hosts = {
      "127.0.0.2" = [
        "cork.meep.sh"
        "remote.dev"
      ];
    };
  };
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
