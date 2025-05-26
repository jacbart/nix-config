{ ... }: {
  imports = [
    ../apps/firefox.nix
  ];
  programs.gpg.enable = true;

  services.gpg-agent.enable = true;
}
