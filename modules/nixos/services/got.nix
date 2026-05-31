{
  pkgs,
  inputs,
  var,
  ...
}:
let
  pkg = inputs.got.packages.${pkgs.stdenv.hostPlatform.system}.default;
  port = 8082;
  user = "git";
  group = "git";
  repoRoot = "/git";
  subdomain = "got";
in
{
  users.groups.${group} = { };
  users.users.${user} = {
    description = "Git repositories";
    isSystemUser = true;
    home = repoRoot;
    group = group;
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1ssGFun8as4ZCOCHz8lAWHwqbcqBDdj12Z56aHgEdb jack bartlett"
    ];
  };

  systemd.services.got = {
    description = "got git viewer";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = user;
      Group = group;
      ExecStart = "${pkg}/bin/got --root ${repoRoot} --addr 127.0.0.2:${toString port}";
      Restart = "on-failure";
      RestartSec = "5s";
      ReadOnlyPaths = [ repoRoot ];
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."${subdomain}.${var.domain}" = {
      addSSL = true;
      useACMEHost = var.domain;
      locations."/" = {
        proxyPass = "http://127.0.0.2:${toString port}";
        extraConfig =
          # required when the target is also TLS server with multiple hosts
          "proxy_ssl_server_name on;"
          +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
      };
    };
  };
}
