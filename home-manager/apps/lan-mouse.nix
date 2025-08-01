{
  inputs,
  pkgs,
  ...
}:
{
  # add the home manager module
  imports = [ inputs.lan-mouse.homeManagerModules.default ];

  programs.lan-mouse = {
    enable = true;
    systemd = false;
    package = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # Optional configuration in nix syntax, see config.toml for available options
    settings = {
      capture-backend = "layer-shell";
      release_bind = [
        "KeyA"
        "KeyS"
        "KeyD"
        "KeyF"
      ];
      port = 4242;
      clients = [
        {
          position = "left";
          hostname = "jackjrny.local";
          activate_on_startup = true;
          ips = [
            "192.168.0.224"
            "100.127.159.128"
          ];
          port = 4242;
        }
      ];
    };
  };
}
