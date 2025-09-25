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
      capture-backend = "macos";
      release_bind = [
        "KeyA"
        "KeyS"
        "KeyD"
        "KeyF"
      ];
      port = 4242;
      clients = [
        {
          position = "right";
          hostname = "boojum";
          activate_on_startup = false;
          ips = [
            "192.168.0.253"
            "100.118.9.78"
          ];
          port = 4242;
        }
      ];
      authorized_fingerprints = {
        "9f:30:6c:ed:88:5e:06:f0:86:32:e1:12:01:5b:1e:31:8f:79:e2:94:25:57:94:8e:18:5e:8d:73:e3:c8:79:b8" =
          "boojum-inbound";
      };
    };
  };
}
