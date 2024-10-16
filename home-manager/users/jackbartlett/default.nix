{ config, ... }: {
    imports = [
        ../../apps/wezterm.nix
        ../../apps/zed-editor.nix
    ];

    # home.file."${config.xdg.configHome}/lan-mouse/config.toml".text = builtins.readFile ./lan-mouse.toml;
}
