# RetroArch for the uConsole (CM4): minimal libretro core set.
# ROMs live in ~/ROMs (user-managed, not in git).
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.retroarch.withCores (
      cores: with cores; [
        mgba # GBA
        snes9x # SNES
        pcsx-rearmed # PSX (aarch64 dynarec)
      ]
    ))
    pkgs.libretro-core-info
  ];

  # RetroArch rewrites its config on exit; a store symlink makes those writes
  # fail (harmless warning), so keep this minimal — only what the CM4 needs.
  xdg.configFile."retroarch/retroarch.cfg".text = ''
    video_threaded = "true"
    video_fullscreen = "true"
    video_windowed_fullscreen = "false"
    menu_driver = "ozone"
    assets_directory = "${pkgs.retroarch-assets}/share/retroarch/assets"
    libretro_info_path = "${pkgs.libretro-core-info}/share/retroarch/cores"
    # keybinds (RetroArch defaults, pinned): F fullscreen, F1 menu, Esc quit
    input_toggle_fullscreen = "f"
    input_menu_toggle = "f1"
    input_exit_emulator = "escape"
  '';
}
