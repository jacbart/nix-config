{ pkgs, ... }: {
    home = { 
        packages = [ pkgs.unstable.wezterm ];
        file.".wezterm.lua".text = builtins.readFile ./wezterm.lua;
    };
}
