{
  pkgs,
  vars,
  ...
}:
let
  subdomain = "files";
  domain = vars.domain;
  host = "127.0.0.2";
  port = 8080;
  dataDir = "/trunk/sftpgo";
in
{
  services.sftpgo = {
    enable = true;
    inherit dataDir;
    extraReadWriteDirs = [ dataDir ];

    settings.httpd.bindings = [
      {
        address = host;
        inherit port;
        enable_web_admin = true;
        enable_web_client = true;
      }
    ];
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0700 sftpgo sftpgo -"
  ];

  systemd.services.sftpgo = {
    after = [ "zfs.target" ];
    requires = [ "zfs.target" ];
  };

  services.nginx = {
    enable = true;
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://${host}:${builtins.toString port}";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };
}
