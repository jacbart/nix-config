{ ... }: {
  imports = [
    ../_mixins/hardware/uconsole.nix
  ];

  overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
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
