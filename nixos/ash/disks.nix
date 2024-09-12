{ disks ? [ "/dev/mmcblk0" ], ... }:
let
  vfatOpts = [ "nofail" "noauto" ];
  ext4Opts = [ "x-initrd" "mount" ];
in
{
  disko.devices = {
    disk = {
      mmcblk2 = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            FIRMWARE = {
              name = "firmware";
              size = "30M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/firmware";
                mountOptions = vfatOpts;
              };
            };
            NIXOS_SD = {
              name = "nixos";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = ext4Opts;
              };
            };
          };
        };
      };
    };
  };
}
