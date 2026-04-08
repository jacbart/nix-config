{ pkgs, ... }:
{
  imports = [
    ./bottom.nix
    ./broot.nix
    ./eza.nix
    ./git-lite.nix
    ./helix-lite.nix
    ./tmux.nix
    ./zoxide.nix
  ];

  home = {
    packages = with pkgs; [
      fd
      fzf
      ripgrep
    ];
    sessionVariables = {
      MANROFFOPT = "-c";
      MANPAGER = "sh -c 'col -bx | bat -plman'";
    };
  };

  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batwatch
        prettybat
      ];
    };
    dircolors = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
  };
}
