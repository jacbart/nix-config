{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.unstable.firefox;
    # preferencesStatus = "locked";
    # languagePacks = [ "en-US" ];
  };
}
