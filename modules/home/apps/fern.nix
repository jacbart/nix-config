{ ... }:
{
  xdg.configFile."fern/config.toml".text = ''
    theme = "gruvbox-dark"

    [keybindings]
    preset = "helix"
  '';
}
