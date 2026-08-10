{
  pkgs,
  lib,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;

  # foot's terminfo entry, dumped from nixpkgs' ncurses db (which ships foot).
  # It must be compiled on the Mac with the *system* tic: Apple's ancient
  # ncurses (6.0 — /bin/zsh, /usr/bin/*) can't parse nix-compiled entries, and
  # /usr/share/terminfo has no foot, so ssh sessions arriving with TERM=foot
  # failed with "'foot': unknown terminal type". ~/.terminfo is searched by
  # both Apple and nix ncurses, ahead of TERMINFO_DIRS below.
  footTerminfo = pkgs.runCommand "foot.info" { } ''
    ${lib.getExe' pkgs.ncurses "infocmp"} -x foot > $out
  '';
in
{
  imports = [
    ./docker-darwin.nix
    ./bottom.nix
    # ./bitwarden.nix
    ./broot.nix
    ./eza.nix
    ./git.nix
    ./helix.nix
    # ./neofetch.nix
    ./tmux.nix
    ./zoxide.nix
  ];

  home = {
    packages = with pkgs; [
      # angle-grinder
      # dysk # disable for m1 mac
      fastfetch
      fd
      fzf
      # htmlq
      # hyperfine
      # unstable.infisical
      netcat
      # nurl
      # nix-melt
      # mazter
      procs
      # rainfrog
      ripgrep
      sd
      xh
    ];
    sessionVariables = {
      MANROFFOPT = "-c";
      MANPAGER = "sh -c 'col -bx | bat -plman'";
    }
    # nix-darwin HM has no Linux-style terminfo wiring; ncurses carries tmux-256color etc.
    // lib.optionalAttrs isDarwin {
      TERMINFO_DIRS = "${pkgs.ncurses}/share/terminfo";
    };
  };

  # Compile foot's terminfo with the macOS system tic into ~/.terminfo so TERM=foot
  # resolves for every consumer here (Apple ncurses and nix ncurses alike).
  home.activation.terminfoFootDarwin = lib.mkIf isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /usr/bin/tic -x -o "$HOME/.terminfo" ${footTerminfo}
    ''
  );

  # default shell programs
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
    # direnv = {
    #   enable = true;
    #   enableZshIntegration = true;
    #   silent = true;
    #   nix-direnv = {
    #     enable = true;
    #     # package = pkgs.lixPackageSets.stable.nix-direnv;
    #   };
    # };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
  };
}
