{
  pkgs,
  lib,
  username,
  desktop,
  ...
}:
let
  isPhosh = desktop == "phosh";
  isNiri = desktop == "niri";
in
{
  # The CM4 has no usable suspend (no S3 on bcm2711; s2idle wedges the
  # USB/DSI stack and the device can only be recovered by a hard power
  # cycle). Any desktop that auto-suspends on inactivity would make the
  # device unrecoverable. Hard-disable it at the systemd level so it
  # applies regardless of which session manager is running.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowSuspendThenHibernate = false;
    AllowHybridSleep = false;
  };

  # Panel backlight control: the ocp8178 backlight device is root-only by
  # default; give the video group (session user is a member) write access so
  # brightnessctl works, and ship brightnessctl for key handlers/debugging.
  environment.systemPackages = [ pkgs.brightnessctl ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
  '';

  # ─── phosh-specific hacks ──────────────────────────────────────────────

  # GNOME settings-daemon (phosh) would auto-suspend or dim on idle.
  # Disable both via dconf. Not needed under niri (no gsd).
  programs.dconf.enable = isPhosh;
  programs.dconf.profiles.user.databases = lib.optional isPhosh {
    settings."org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
      idle-dim = false;
    };
  };

  # phosh 0.54 does not handle XF86MonBrightness keys (verified on-device:
  # key events arrive but brightness never changes). The uConsole keyboard
  # MCU emits standard KEY_BRIGHTNESSDOWN/UP (224/225; evdev-captured on
  # the "ClockworkPI uConsole Consumer Control" device), so handle them
  # with actkbd, which auto-instantiates on every input device via udev.
  # Panel max_brightness is 9, so step in raw units, not percent.
  # (Fn+Space keyboard backlight is MCU-internal — no OS involvement.)
  # Under niri, niri itself grabs XF86MonBrightness keys (see config.kdl),
  # so actkbd is not needed.
  services.actkbd = lib.mkIf isPhosh {
    enable = true;
    bindings = [
      {
        keys = [ 224 ];
        events = [ "key" "rep" ];
        command = "${pkgs.brightnessctl}/bin/brightnessctl set 1-";
      }
      {
        keys = [ 225 ];
        events = [ "key" "rep" ];
        command = "${pkgs.brightnessctl}/bin/brightnessctl set +1";
      }
    ];
  };

  # Tell phosh (via hostnamed's Chassis, sourced from /etc/machine-info)
  # that this is a convertible, NOT a phone. phosh's rotation manager
  # (fixup_lockscreen_orientation) forces the lockscreen to transform
  # NORMAL (portrait) on every lock when the device type is phone/UNKNOWN
  # — correct on handsets, but on the uConsole's sideways panel that makes
  # the lockscreen 90° off whenever the session is landscape. Convertibles
  # skip that fixup, so the lockscreen simply follows the session
  # transform. (Convertible also keeps PHOSH_MODE_HW_KEYBOARD set, so the
  # on-screen keyboard doesn't pop up over the physical one.)
  # Under niri this is irrelevant (niri doesn't read chassis).
  environment.etc."machine-info".text = lib.optionalString isPhosh "CHASSIS=convertible\n";

  # ─── panel cold-boot heal ──────────────────────────────────────────────
  # The CWU50 panel's first init after a cold boot leaves the screen dark
  # (DSI/vc4 first-modeset quirk); any later DPMS off/on cycle revives it —
  # this is why "press power again" appeared to fix booting. There is no
  # reliable dark-panel signal to gate on (the driver's dsi_state reads "ok"
  # even when dark), and /sys/class/drm/*/dpms is read-only on 6.18, so
  # force one full display-stack restart shortly after boot.
  systemd.services.uconsole-panel-heal = lib.mkMerge [
    # phosh variant: restart phosh.service, then re-apply rotation via
    # Mutter DisplayConfig (phosh 0.54 has no monitor persistence).
    (lib.mkIf isPhosh (
      let
        gdbus = "${pkgs.glib.bin}/bin/gdbus";
        rotate = pkgs.writeShellScript "uconsole-rotate" ''
          for _ in $(seq 1 45); do
            out=$(${gdbus} call --session --dest org.gnome.Mutter.DisplayConfig \
              --object-path /org/gnome/Mutter/DisplayConfig \
              --method org.gnome.Mutter.DisplayConfig.GetCurrentState 2>/dev/null) || { sleep 1; continue; }
            cur=$(printf '%s' "$out" | ${pkgs.gnugrep}/bin/grep -oE '\(0, 0, 1\.0, uint32 [0-9]+' | ${pkgs.gnugrep}/bin/grep -oE '[0-9]+$')
            [ "$cur" = "3" ] && exit 0
            serial=$(printf '%s' "$out" | ${pkgs.gnused}/bin/sed -n 's/^(uint32 \([0-9]*\).*/\1/p')
            [ -n "$serial" ] && ${gdbus} call --session \
              --dest org.gnome.Mutter.DisplayConfig \
              --object-path /org/gnome/Mutter/DisplayConfig \
              --method org.gnome.Mutter.DisplayConfig.ApplyMonitorsConfig \
              "$serial" 2 "[(0,0,1.0,3,true,[(\"DSI-1\",\"720x1280@60\",{})])]" "{}" >/dev/null 2>&1
            sleep 2
          done
        '';
      in
      {
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
          # The session the restart spawns needs its rotation (re)applied; the
          # loop converges once phosh stops touching the config, and the
          # correct transform then survives locks (see machine-info above).
          # Runs as the session user on the session bus.
          ExecStartPost = "${pkgs.util-linux}/bin/runuser -u ${username} -- env DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus ${rotate}";
        };
      }
    ))
    # niri variant: restart greetd, which respawns niri-session. niri reads
    # its output config (transform, mode) from config.kdl at startup, so no
    # post-restart rotation step is needed (unlike phosh).
    (lib.mkIf isNiri {
      description = "Restart the display stack once to revive the DSI panel";
      wantedBy = [ "graphical.target" ];
      after = [ "greetd.service" ];
      serviceConfig = {
        Type = "oneshot";
        # Give niri time to come up and do the initial (dark) modeset before
        # cycling the session (greetd auto-logins via initial_session).
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 20";
        ExecStart = "${pkgs.systemd}/bin/systemctl restart greetd.service";
      };
    })
  ];
}
