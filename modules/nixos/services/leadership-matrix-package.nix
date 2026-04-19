# leadership-matrix default package with cargo feature set for this host.
{
  pkgs,
  inputs,
  nativeComponents,
}:
inputs.leadership-matrix.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
  inherit nativeComponents;
}
