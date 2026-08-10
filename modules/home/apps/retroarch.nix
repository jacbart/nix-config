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
    menu_driver = "ozone"
    assets_directory = "${pkgs.retroarch-assets}/share/retroarch/assets"
    libretro_info_path = "${pkgs.libretro-core-info}/share/retroarch/cores"
  '';
}
