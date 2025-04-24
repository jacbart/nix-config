{ pkgs, ... }:
let
  # -a: Monitors all attributes
  # -o on: Enables automatic offline testing
  # -S on: Enables attribute autosave
  # -n standby,q: Don’t check if disk is in standby, and be quiet about it
  # -s (S//./02|L//6/03): Schedule short self-tests daily at 2am, and long self-tests weekly on Saturdays at 3am
  # -W 4,35,40: Sets temperature thresholds (low, high, critical)
  # -m root: Send email alerts to root user
  options = "-a -o on -S on -n standby,q -s (S//./02|L//6/03) -W 4,35,40 -m root";
in
{
  environment.systemPackages = with pkgs; [
    # nvme-cli
    smartmontools
  ];
  # ++ lib.optionals (desktop != null) [
  #   gsmartcontrol
  # ];

  services.smartd = {
    enable = true;
    autodetect = false;
    devices = [
      # {
      #   device = "/dev/mmcblk2";
      #   inherit options;
      # }
      {
        device = "/dev/sda";
        inherit options;
      }
      {
        device = "/dev/sdb";
        inherit options;
      }
    ];
  };
}
