{
  inputs,
  pkgs,
  ...
}:
let
  lanMouse = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  # add the home manager module
  imports = [ inputs.lan-mouse.homeManagerModules.default ];

  programs.lan-mouse = {
    enable = true;
    systemd = true;
    package = lanMouse;
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
          hostname = "sycamore";
          activate_on_startup = true;
          ips = [
            "192.168.0.30"
          ];
          port = 4242;
        }
      ];
    };
  };
}
