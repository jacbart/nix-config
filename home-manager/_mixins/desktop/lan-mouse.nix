{ inputs, pkgs, ... }: {
  # add the home manager module
  imports = [inputs.lan-mouse.homeManagerModules.default];

  programs.lan-mouse = {
    enable = true;
    systemd = true;
    package = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # Optional configuration in nix syntax, see config.toml for available options
    settings = {
      release_bind = [ "KeyA" "KeyS" "KeyD" "KeyF" ];
      port = 4242;
      left = {
        hostname = "jackjrny.local";
        ips = [ "192.168.1.54" ];
        port = 4242;
      };
    };
  };
}
