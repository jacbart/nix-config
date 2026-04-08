{
  inputs,
  pkgs,
  ...
}:
let
  lanMouse = inputs.lan-mouse.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  imports = [ inputs.lan-mouse.homeManagerModules.default ];

  programs.lan-mouse = {
    enable = true;
    package = lanMouse;
    systemd = !pkgs.stdenv.isDarwin;
    settings =
      if pkgs.stdenv.isDarwin then
        {
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
              hostname = "cork";
              activate_on_startup = false;
              ips = [
                "192.168.0.137"
                "100.113.192.12"
              ];
              port = 4242;
            }
          ];
          authorized_fingerprints = {
            "f1:bd:d1:77:33:22:08:6a:1a:b9:d5:6a:fc:c5:78:c2:f9:34:99:50:95:65:c8:8c:c3:92:c3:6d:57:13:16:18" =
              "cork-inbound";
          };
        }
      else
        {
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
              hostname = "sycamore.local";
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
