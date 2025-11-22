{
  disks ? [
    "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S59ANMFNB18932X"
    "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S59ANMFNB18929M"
  ],
  ...
}:
{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            root = {
              size = "100%";
              label = "root";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                  "--data raid0"
                  "--metadata raid0"
                  builtins.elemAt
                  disks
                  1
                ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=root"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=home"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=persist"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=log"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16G";
                  };
                };
              };
            };
          };
        };
      };
      nvme1n1 = {
        type = "disk";
        device = builtins.elemAt disks 1;
        size = "100%";
        content = {
          type = "btrfs";
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
