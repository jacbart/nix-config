{ pkgs, ... }:
{
  # imports = [
  #   ../apps/firefox.nix
  # ];
  home = {
    packages = with pkgs; [
      unstable.bitwarden-desktop
      unstable.element-desktop
      unstable.librewolf
      unstable.vivaldi
    ];
  };
  programs.gpg.enable = true;

  services.gpg-agent.enable = true;
}
