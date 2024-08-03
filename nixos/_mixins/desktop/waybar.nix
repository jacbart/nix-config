{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        (pkgs.waybar.overrideAttrs (oldAttrs: {
            mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
        }))
    ];
}