{ config, ... }: {
    imports = [
        ../../desktop/wezterm.nix
    ];

    home.file."${config.xdg.configHome}/lan-mouse/config.toml".text = builtins.readFile ./lan-mouse.toml;
}
