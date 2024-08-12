{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.unstable.firefox-unwrapped;
    preferencesStatus = "locked";
    languagePacks = [ "en-US" ];
  };
}
