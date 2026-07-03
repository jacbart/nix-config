# Internal bridge flag — NOT the host-facing toggle.
# Hosts enable Salesforce by adding ../../home/dev/salesforce to their modules
# list (see modules/hosts/sycamore/home.nix). This option only exists so
# shell/tools/helix.nix can append lwc-lsp to the javascript language-servers
# without duplicating the [[language]] block. Imported by both default.nix and
# helix.nix; the module system dedupes the shared path.
{ lib, ... }:
{
  options.dev.salesforce.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "True when modules/home/dev/salesforce is in the host's module list.";
  };
}
