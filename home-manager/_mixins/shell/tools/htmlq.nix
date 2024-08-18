{ pkgs, ... }: {
  home.packages = with pkgs; [
    htmlq
  ];
}
