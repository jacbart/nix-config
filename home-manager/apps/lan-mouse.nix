{ inputs
, pkgs
, ...
}: {
  # add the home manager module
  imports = [ inputs.lan-mouse.homeManagerModules.default ];

  programs.lan-mouse = {
    enable = true;
    systemd = true;
    package = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # Optional configuration in nix syntax, see config.toml for available options
    settings = {
      capture-backend = "layer-shell";
      release_bind = [ "KeyA" "KeyS" "KeyD" "KeyF" ];
      port = 4242;
      left = {
        hostname = "jackjrny";
        activate_on_startup = true;
        ips = [ "192.168.1.3" "100.127.159.128" ];
        port = 4242;
      };
    };
  };
}
