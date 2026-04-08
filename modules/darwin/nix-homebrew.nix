# nix-homebrew: Nix-managed Homebrew install + nix-darwin homebrew.* for formulae/casks
# https://github.com/zhaofengli/nix-homebrew

{ ... }:
{
  flake.modules.darwin.nix-homebrew =
    { username, inputs, ... }:
    {
      imports = [
        inputs.nix-homebrew.darwinModules.nix-homebrew
        (
          { config, ... }:
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = username;
              autoMigrate = true;
              taps = {
                "homebrew/homebrew-core" = inputs.homebrew-core;
                "homebrew/homebrew-cask" = inputs.homebrew-cask;
              };
              mutableTaps = false;
            };

            homebrew = {
              enable = true;
              user = username;
              taps = builtins.attrNames config.nix-homebrew.taps;
              brews = [
                "awscli"
                "go"
                "pulumi"
              ];
              casks = [
                "1password-cli"
                "claude-code"
                "ghostty"
              ];
            };
          }
        )
      ];
    };
}
