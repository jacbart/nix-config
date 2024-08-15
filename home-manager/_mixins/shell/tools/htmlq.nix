{ pkgs, ... }: {
  home.packages = with pkgs; [
    polkit-kde-agent
  ];
}
