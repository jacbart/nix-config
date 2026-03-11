{
  inputs,
  vars,
  hostname,
  ...
}:
let
  port = "13121";
in
{
  imports = [ inputs.leadership-matrix.nixosModules.default ];

  services.leadership-matrix = {
    enable = true;

    # Web server bind address
    host = "127.0.0.2:${port}";

    # Run as a specific user/group
    user = "root";
    group = "root";

    workingDirectory = "/var/lib";

    extraEnv = {
      RUST_LOG = "info";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."${hostname}.${vars.domain}" = {
      addSSL = true;
      useACMEHost = vars.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:${port}";
        proxyWebsockets = true;
      };
    };
  };
}
