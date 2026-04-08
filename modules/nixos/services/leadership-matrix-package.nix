# leadership-matrix default package with cargo feature set for this host.
{
  pkgs,
  inputs,
  cargoFeatures,
}:
inputs.leadership-matrix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
  inherit cargoFeatures;
}
