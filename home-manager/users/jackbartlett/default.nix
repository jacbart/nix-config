{ pkgs, ... }:
{
  imports = [
    ./lan-mouse.nix
    # ../../apps/wezterm.nix
    # ../../apps/zed-editor.nix
  ];

  home.packages = with pkgs; [
    gitu
    taskwarrior3
    scripts.alfred
  ];

  # home.file."${config.xdg.configHome}/lan-mouse/config.toml".text = builtins.readFile ./lan-mouse.toml;
}
