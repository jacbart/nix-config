{ pkgs, ... }: {
  imports = [
    ../_mixins/hardware/uconsole.nix
    # ../_mixins/services/flatpak.nix
    ./remote-builder.nix
    ./wireguard.nix
  ];

  environment.systemPackages = with pkgs; [
    unstable.nxengine-evo
  ];

  fileSystems = { 
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "x-initrd"
      ];
    };
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
