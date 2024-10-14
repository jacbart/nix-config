{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.unstable.firefox;
    # preferencesStatus = "default";
    # preferences = {
    #   accessibility.typeaheadfind.flashBar = 0;
      
    # };
    # languagePacks = [ "en-US" ];
  };
}
