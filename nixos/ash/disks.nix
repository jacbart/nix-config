{ disks ? [ "/dev/mmcblk0" ], ... }:
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
          type = "gpt";
          partitions = {
            root = {
              name = "nixos";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = defaultExt4Opts;
              };
            };
          };
        };
      };
    };
  };
}
