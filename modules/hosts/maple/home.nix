{ config, ... }:
{
  homeHosts."ratatoskr@maple" = {
    system = "aarch64-linux";
    shellProfile = "zsh-lite";
    modules = [
      config.flake.modules.homeManager.core
      ../../home/shell/default.nix
      ../../home/users/ratatoskr/default.nix
    ];
  };
}
