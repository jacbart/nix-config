{ desktop, lib, pkgs, ... }: {
    imports = [
    ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix")) ./${desktop}.nix
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}-apps.nix")) ./${desktop}-apps.nix;

    boot = {
    kernelParams = [ "loglevel=4" ];
        plymouth = {
            enable = true;
            theme = "solar";
        };
    };

    hardware = {
        opengl = {
            enable = true;
            driSupport = true;
        };
    };

    programs.nix-ld.dev.libraries = with pkgs; [
        openal # ludo
        libGL # ludo
    ];
}
