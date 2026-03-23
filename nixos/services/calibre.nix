{
  pkgs,
  lib,
  vars,
  ...
}:
let
  subdomain = "calibre";
  addr = "127.0.0.2";
  port = 8235;
  domain = vars.domain;
  # Use python313 wand for nixpkgs-unstable which uses python313
  wand_0_6 = pkgs.unstable.python313Packages.wand.overrideAttrs (old: {
    version = "0.6.13";
    src = pkgs.unstable.python313Packages.fetchPypi {
      pname = "Wand";
      version = "0.6.13";
      hash = "sha256-+BJTpXPXFlWJ/5akqIzNfR7BTL2n0IXl4RtrMUCg7kE=";
    };
  });
  calibreWebPackage = pkgs.unstable.calibre-web.overridePythonAttrs (old: {
    dependencies =
      let
        filteredDeps = builtins.filter (dep: !(dep.pname == "wand")) (old.dependencies or [ ]);
      in
      filteredDeps ++ [ wand_0_6 ] ++ lib.concatLists (lib.attrValues old.optional-dependencies);
  });
in
{
  services.calibre-web = {
    enable = true;
    package = calibreWebPackage;
    group = "media";
    listen = {
      ip = addr;
      inherit port;
    };
    openFirewall = true;
    options = {
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };

  services.nginx = {
    enable = true;
    clientMaxBodySize = "0";
    virtualHosts."${subdomain}.${domain}" = {
      addSSL = true;
      useACMEHost = domain;
      locations."/" = {
        proxyPass = "http://${addr}:${builtins.toString port}";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_max_temp_file_size 0;
          proxy_read_timeout 300s;
        '';
      };
    };
  };
}
