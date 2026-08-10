# RetroArch for the uConsole (CM4): minimal libretro core set.
# ROMs live in ~/ROMs (user-managed, not in git).
{ config, pkgs, ... }:
{
  home.packages = [
    (pkgs.retroarch.withCores (
      cores: with cores; [
        mgba # GBA
        # snes9x # SNES
        pcsx-rearmed # PSX (aarch64 dynarec)
      ]
    ))
    pkgs.libretro-core-info
    # NOTE: no libretro-database in nixpkgs 26.05 — use RetroArch's Online
    # Updater once on-device (Update Databases / Update Cheats); files land
    # in the default ~/.config/retroarch/database paths.
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
    rgui_browser_directory = "${config.home.homeDirectory}/ROMs"
    # Boxart/title screens auto-download while browsing playlists
    menu_show_online_updater = "true"
    # keybinds (RetroArch defaults, pinned): F fullscreen, F1 menu, Esc quit
    input_toggle_fullscreen = "f"
    input_menu_toggle = "f1"
    input_exit_emulator = "escape"
  '';
}
