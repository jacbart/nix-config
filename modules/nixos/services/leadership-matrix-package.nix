# leadership-matrix package for this host.
#
# The `simple` branch ships a single package per system; nvidia support is
# dlopen'd at runtime (see `runtime::probe_nvml`), not compiled in, so there is
# no per-host native-components customization anymore.
{
  pkgs,
  inputs,
  ...
}:
inputs.leadership-matrix.packages.${pkgs.stdenv.hostPlatform.system}.default
