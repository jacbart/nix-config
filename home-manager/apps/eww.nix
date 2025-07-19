{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    eww
  ];

  services.playerctld = {
    enable = true;
    package = pkgs.playerctl;
  };

  home.file."${config.xdg.configHome}/eww".source = builtins.fetchGit {
    url = "https://github.com/jacbart/eww";
    rev = "3d74fb407236a059e8b5399dff2b6eefb4587ed1";
    ref = "main";
  };
}
