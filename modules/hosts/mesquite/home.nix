{ config, ... }:
{
  homeHosts."ratatoskr@mesquite" = {
    system = "x86_64-linux";
    shellProfile = "lite";
    modules = [
      config.flake.modules.homeManager.core
      ../../home/shell/default.nix
      ../../home/users/ratatoskr/default.nix
    ];
  };
}
