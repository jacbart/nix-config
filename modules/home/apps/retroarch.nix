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
    # Ozone menu color theme: 3 == Gruvbox Dark
    # (enum: 0 Basic White, 1 Basic Black, 2 Nord, 3 Gruvbox Dark, ...)
    ozone_menu_color_theme = "3"
    # uConsole L/R shoulder buttons are the mouse left/right click buttons
    # (stock keyboard firmware: L=Mouse.press(1), R=Mouse.press(2); trackball
    # click is middle). Bind them to RetroPad L/R so GBA/PSX shoulder buttons
    # work in-game. _mbtn map (input_config_parse_mouse_button): 1=left, 2=right.
    input_player1_l_mbtn = "1"
    input_player1_r_mbtn = "2"
    # keybinds (RetroArch defaults, pinned): F fullscreen, F1 menu, Esc quit
    input_toggle_fullscreen = "f"
    input_menu_toggle = "f1"
    input_exit_emulator = "escape"
  '';
}
