{ ... }: {
  imports = [
    ../_mixins/hardware/uconsole.nix
    ./remote-builder.nix
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

  networking = {
    hosts = {
      "127.0.0.1" = [ "ash" "ash.meep.sh"  ];
      "192.168.0.120" = [ "mesquite" "mesquite.meep.sh" ];
    };
    wireless.iwd = {
      enable = true;
      settings = {
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
        };
        Settings = {
          AutoConnect = true;
        };
      };
    };
  };
}
