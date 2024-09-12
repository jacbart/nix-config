{ ... }: {
  imports = [
    ../_mixins/hardware/uconsole.nix
  ];

  fileSystems = { 
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "x-initrd"
      ];
    };
    # "/boot/firmware" = {
    #   device = "/dev/disk/by-label/FIRMWARE";
    #   fsType = "vfat";
    #   options = [
    #     "nofail"
    #     "noauto"
    #   ];
    # };
  };
}
