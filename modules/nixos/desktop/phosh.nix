{ pkgs, username, ... }:
{
  # NOTE: the phosh NixOS module launches phosh-session directly on tty1 as
  # the session user ("running without a display manager"). Do NOT add a
  # display manager (gdm) here: gdm's greeter races phoc for the session
  # (observed: gnome-shell "Failed to take control of the session: EBUSY").
  services.xserver.desktopManager.phosh = {
    enable = true;
    user = username;
    group = "users";
    phocConfig.xwayland = "immediate";
    phocConfig.outputs = {
      DSI-1 = {
        # Clockwise 90 = wl transform 3 (phoc's fix_transform swaps 90<->270
        # to keep ini values clockwise). This rotates the pre-session phoc
        # phase; the session itself is rotated by the rotate step in
        # uconsole-panel-heal (phosh 0.54 has no monitor persistence and
        # applies nothing at startup), and the lockscreen follows the
        # session transform because CHASSIS=convertible (machine-info)
        # disables phosh's force-portrait-on-lock fixup.
        rotate = "90";
        scale = 1;
      };
    };
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Secret Service provider (Newsflash/RSS credentials, future apps).
  services.gnome.gnome-keyring.enable = true;

  # GTK4 defaults to its Vulkan renderer; on v3dv (VC4/VC6) that crashes
  # GTK4 apps at swapchain creation (observed: kgx SIGSEGV in
  # gsk_gpu_renderer_render, VK_ERROR_OUT_OF_DEVICE_MEMORY). Force the GL
  # renderer, which works on v3d.
  environment.sessionVariables.GSK_RENDERER = "ngl";

  environment.systemPackages = with pkgs; [
    baobab # disk usage
    # chatty # XMPP & SMS messaging via libpurple and ModemManager
    decibels # audio player
    epiphany # web browser
    evince # document viewer
    foot # wayland-native terminal (fallback; no GL dependency)
    nautilus # files
    gnome-disk-utility
    gnome-calendar
    gnome-calculator
    gnome-console # term
    gnome-contacts
    gnome-clocks
    gnome-music
    gnome-system-monitor
    gnome-weather
    gmobile
    loupe # image viewer
    totem # video player
  ];
}
