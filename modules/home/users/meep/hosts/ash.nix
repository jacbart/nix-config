# meep@ash only: emulators + RSS clients for the uConsole.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Handheld mode: gates out lan-mouse/zed/rustdesk, drops heavy/x86-only
  # packages, adds DSI-1 output config (rotation comes from the DRM
  # panel-orientation property), raw brightness steps, disables noctalia
  # screen-off idle.
  niri-desktop.handheld = true;

  imports = [
    ../../../apps/retroarch.nix
    ../../../apps/newsboat.nix
  ];

  # Ghostty >=1.3 requires OpenGL 4.3; the CM4's V3D driver tops out at GL 3.1
  # (and ghostty disables the GLES path itself), so it only renders via
  # llvmpipe ("Unable to acquire an OpenGL context" otherwise). Wrap just the
  # binary — not session-wide — so everything else keeps hardware GLES.
  programs.ghostty.package = lib.mkForce (
    pkgs.symlinkJoin {
      name = "ghostty-llvmpipe";
      paths = [ pkgs.ghostty ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      meta.mainProgram = "ghostty";
      postBuild = ''
        rm $out/bin/ghostty
        makeWrapper ${pkgs.ghostty}/bin/ghostty $out/bin/ghostty \
          --set LIBGL_ALWAYS_SOFTWARE 1
      '';
    }
  );

  home.packages = [
    # Touch-friendly FreshRSS client; one-time GUI login, stored in gnome-keyring.
    pkgs.unstable.newsflash
    # Wayland clipboard CLI (wl-copy/wl-paste) — nothing else provides one here.
    pkgs.wl-clipboard
    # Game-streaming wrapper: resolves cork's Tailscale IP at runtime and
    # launches moonlight-embedded (software decode, DRM/KMS fullscreen).
    # H264 only — no HEVC HW decode on BCM2711.
    # Usage: moonlight-ash [app-name]
    pkgs.scripts.moonlight-ash
    # VNC viewer: connects to wayvnc servers on boojum/cork and macOS Screen
    # Sharing on sycamore, all over Tailscale. TigerVNC's vncviewer supports
    # SASL/SCRAM auth (needed for wayvnc's PAM authentication). Runs under
    # XWayland via xwayland-satellite. Connect with: vncviewer <ip>:5900
    pkgs.tigervnc
  ];

  # Discord + Slack ship proprietary x86_64-only binaries (meta.platforms
  # excludes aarch64-linux), so the native nixpkgs packages won't build on the
  # CM4. Run them as Vivaldi PWAs instead — Vivaldi is aarch64-compatible and
  # the vivaldiPwa module is enabled via the niri desktop. Icons are
  # committed locally (the services' CDNs redirect, which fetchurl can't
  # follow). profile = "isolated" gives each its own persistent user-data-dir
  # under ~/.config/vivaldi-pwas/<id> so logins survive independently.
  vivaldiPwa.pwas = {
    "Discord" = {
      url = "https://discord.com/app";
      icon = ../../../files/icons/discord.png;
      profile = "isolated";
    };
    "Slack" = {
      url = "https://app.slack.com";
      icon = ../../../files/icons/slack.ico;
      profile = "isolated";
    };
  };

  # newsboat's freshrss-passwordfile. The FreshRSS API password is the same
  # as the login password, which nix-secrets already holds.
  sops.secrets."freshrss/admin-password" = {
    path = "${config.home.homeDirectory}/.config/newsboat/freshrss-password";
    mode = "0400";
  };
}
