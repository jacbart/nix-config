{ lib, ... }: let 
  certDir = ./certs;
  certFiles = (builtins.readDir certDir);
  loadCerts = cert: builtins.readFile (certDir + "/${cert}");
in {
  imports = [
    ./sops.nix
  ];

  security.pki.certificates = lib.mapAttrsToList (cert: _: loadCerts cert) certFiles;
}
