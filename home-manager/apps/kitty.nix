{ config, pkgs, ... }: {
    home = {
        packages = with pkgs; [
            kitty
        ];
        file."${config.xdg.configHome}/kitty/kitty.conf".text = builtins.readFile ./kitty.conf;
    };
}