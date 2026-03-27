{ config, ... }:
{
  homeHosts."ratatoskr@mesquite" = {
    system = "x86_64-linux";
    modules = [
      ../../home/core.nix
      ../../home/shell/default.nix
      ../../home/shell/tools/default.nix
      ../../home/users/ratatoskr/default.nix
    ];
  };
}
