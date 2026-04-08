# Shared nix-darwin stack for personal laptops (core + Homebrew + Colima/docker + primary user).

{ ... }:
{
  flake.modules.darwin.laptop =
    { flakeModules, username, ... }:
    {
      imports = [
        flakeModules.darwin.core
        flakeModules.darwin.nix-homebrew
        flakeModules.darwin.docker
      ];

      users.users.${username} = {
        home = "/Users/${username}";
        shell = "/run/current-system/sw/bin/zsh";
      };
    };
}
