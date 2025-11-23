{
  disks ? [
    "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S59ANMFNB18932X" # 1tb
    "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S59ANMFNB18929M" # 1tb
    "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_1TB_S3PJNF0JA06227T" # 1tb
    "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_120GB_S21TNXAG816661J" # 120Gb
    "/dev/disk/by-id/ata-HGST_HUS724040ALE640_PK2334PEGMRMPT" # 4tb
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
                  (builtins.elemAt disks 1)
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
                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=log"
                      "compress=zstd"
                      "noatime"
                    ];
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
        content = {
          type = "btrfs";
        };
      };
      sda = {
        type = "disk";
        device = builtins.elemAt disks 2;
        content = {
          type = "gpt";
          partitions = {
            root = {
              size = "100%";
              label = "extra";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "extra"
                  "-f"
                  "--data raid0"
                  "--metadata raid0"
                  (builtins.elemAt disks 3)
                  (builtins.elemAt disks 4)
                ];
                subvolumes = {
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=persist"
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
      sdb = {
        type = "disk";
        device = builtins.elemAt disks 3;
        content = {
          type = "btrfs";
        };
      };
      sdc = {
        type = "disk";
        device = builtins.elemAt disks 4;
        content = {
          type = "btrfs";
        };
      };
    };
  };

  # fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
