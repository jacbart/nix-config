# meep@ash only: emulators + RSS clients for the uConsole.
{
  config,
  pkgs,
  lib,
  ...
}:
{
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
    # Game-streaming client: the CM4 can't run Steam (x86-only client+games);
    # this plays the whole library from a Sunshine host (e.g. cork) instead.
    # H264 only — the BCM2711 has no HEVC hardware decode.
    pkgs.moonlight-qt
  ];

  # newsboat's freshrss-passwordfile. The FreshRSS API password is the same
  # as the login password, which nix-secrets already holds.
  sops.secrets."freshrss/admin-password" = {
    path = "${config.home.homeDirectory}/.config/newsboat/freshrss-password";
    mode = "0400";
  };
}
