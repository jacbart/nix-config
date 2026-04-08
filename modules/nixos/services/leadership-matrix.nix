{
  inputs,
  vars,
  hostname,
  ...
}:
let
  lm = vars.serviceCatalog.leadershipMatrix;
  bindHost = lm.bindHost;
  port = lm.bindPort;
in
{
  imports = [ inputs.leadership-matrix.nixosModules.default ];

  services.leadership-matrix = {
    enable = true;

    # Web server bind address (see vars.serviceCatalog.leadershipMatrix)
    host = "${bindHost}:${port}";

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
      useACMEHost = if hostname == "maple" then vars.domain else "${hostname}.${vars.domain}";
      locations."/" = {
        proxyPass = "http://${bindHost}:${port}";
        proxyWebsockets = true;
      };
    };
  };
}
