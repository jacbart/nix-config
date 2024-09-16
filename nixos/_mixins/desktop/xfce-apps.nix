{ pkgs, ... }: {
  imports = [
    ../services/pipewire.nix
  ];
  
  environment.systemPackages = with pkgs; [
    alacritty
    alacritty-theme
  ];
}
