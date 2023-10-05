{ disks ? [ "/dev/mmcblk2" ], ... }:
let
  defaultExt4Opts = [ "defaults" ];
in
{
  disko.devices = {
    disk = {
      mmcblk2 = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
                name = "idbloader";
                type = "device";
                start = "32.8kB";
                end = "8389kB";
            }
            {
              name = "uboot";
              start = "8389kB";
              end = "16.8MB";
            }
            {
              name = "nixos";
              start = "16.8MB";
              end = "62.5GB";
              bootable = true;
              flags = [ "legacy_boot" ];
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = defaultExt4Opts;
              };
            }
          ];
        };
      };
    };
  };
}
