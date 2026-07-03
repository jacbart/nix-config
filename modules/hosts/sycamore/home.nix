{ config, ... }:
{
  homeHosts."jackbartlett@sycamore" = {
    system = "aarch64-darwin";
    shellProfile = "dev-heavy";
    modules = [
      config.flake.modules.homeManager.core
      ../../home/shell/default.nix
      ../../home/dev/salesforce # Salesforce dev: Apex/LWC/SOQL toolchain + Helix wiring
      ../../home/users/jackbartlett/default.nix
      ./git-1password.nix
    ];
  };
}
