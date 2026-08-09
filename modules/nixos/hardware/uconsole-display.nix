{ pkgs, lib, ... }:
{
  # The CM4 has no usable suspend (no S3 on bcm2711; s2idle wedges the
  # USB/DSI stack and the device can only be recovered by a hard power
  # cycle). phosh/GNOME would otherwise auto-suspend on inactivity, which
  # presented as "screen turned off and won't come back". Hard-disable it.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowSuspendThenHibernate = false;
    AllowHybridSleep = false;
  };

  # Screen blanking on idle is fine (DSI DPMS off/on works once the panel is
  # up), but never auto-suspend and don't dim first (dim -> wake also goes
  # through the flaky panel path).
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-type = "nothing";
        idle-dim = false;
      };
    }
  ];

  # The CWU50 panel's first init after a cold boot leaves the screen dark
  # (DSI/vc4 first-modeset quirk); any later DPMS off/on cycle revives it —
  # this is why "press power again" appeared to fix booting. There is no
  # reliable dark-panel signal to gate on (the driver's dsi_state reads "ok"
  # even when dark), and /sys/class/drm/*/dpms is read-only on 6.18, so force
  # one full display-stack restart shortly after boot.
  systemd.services.uconsole-panel-heal = {
    description = "Restart the display stack once to revive the DSI panel";
    wantedBy = [ "graphical.target" ];
    after = [ "phosh.service" ];
    serviceConfig = {
      Type = "oneshot";
      # Give phoc/phosh time to come up before cycling them (there is no
      # display-manager on this system; the phosh module runs the session
      # directly on tty1 with Restart=always).
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 20";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart phosh.service";
    };
  };
}
