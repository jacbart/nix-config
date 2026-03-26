{
  config,
  lib,
  ...
}:
let
  certDir = ./certs;
  certFiles = builtins.readDir certDir;
  loadCerts = cert: builtins.readFile (certDir + "/${cert}");
in
{
  imports = [
    ./sops.nix
  ];

  sops.secrets."nix-cache-key" = { };
  sops.secrets."harmonia/secret" = { };
  sops.secrets."harmonia/pub" = { };

  security.pki.certificates = lib.mapAttrsToList (cert: _: loadCerts cert) certFiles;

  environment.etc."nix/cache.key".source = config.sops.secrets."nix-cache-key".path;
}
