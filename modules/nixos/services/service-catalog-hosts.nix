# Applies vars.serviceCatalog.localVhosts.<hostName> to networking.hosts when defined.
{
  config,
  lib,
  vars,
  ...
}:
let
  host = config.networking.hostName;
  lv = vars.serviceCatalog.localVhosts or { };
in
lib.mkIf (builtins.hasAttr host lv) {
  networking.hosts = lv.${host};
}
