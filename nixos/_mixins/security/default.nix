{ lib, ... }: let 
  certDir = ./certs;
  certFiles = (builtins.readDir certDir);
  loadCerts = cert: builtins.readFile (certDir + "/${cert}");
in {
  security.pki.certificates = lib.mapAttrsToList (cert: _: loadCerts cert) certFiles;
}
