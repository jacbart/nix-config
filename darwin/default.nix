{
  lib,
  username,
  vars,
  ...
}:
{
  users.users.${username} = {
    home = "/Users/${username}";
    shell = lib.mkDefault "/run/current-system/sw/bin/zsh";
  };

  programs.zsh.enable = true;

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };
    optimise.automatic = true;
    settings = {
      trusted-users = [
        username
        "root"
      ];
      substituters = [
        "https://nix-cache.${vars.domain}"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nix-cache.${vars.domain}-1:XXAOd8QBIGcdFKorIt/nY+MP6DTJWA63h1zFyJfEzQM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };

  system.stateVersion = 6;
}
