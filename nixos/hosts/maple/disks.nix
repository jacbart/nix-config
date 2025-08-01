{
  disks ? [
    "/dev/mmcblk2"
    "/dev/sda"
    "/dev/sdb"
  ],
  ...
}:
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
            idloader = {
              name = "idloader";
              size = "8M";
            };
            uboot = {
              name = "uboot";
              size = "8M";
            };
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
      # sda = {
      #   type = "disk";
      #   device = builtins.elemAt disks 1;
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       root = {
      #         size = "100%";
      #         content = {
      #           type = "filesystem";
      #           format = "ext4";
      #           mountpoint = "/";
      #           mountOptions = defaultExt4Opts;
      #         };
      #       };
      #     };
      #   };
      # };
    };
  };
}
