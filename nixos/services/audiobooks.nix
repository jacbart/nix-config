{ pkgs, ... }: {
  imports = [ ./audiobookshelf.nix ];

  environment.systemPackages = [ pkgs.unstable.libation ];
}
