{ pkgs, ... }:
{
  users.groups.media = { };

  imports = [
    ./audiobookshelf.nix
    ./calibre.nix
  ];

  environment.systemPackages = [
    pkgs.unstable.libation
    # pkgs.libro
  ];
}
