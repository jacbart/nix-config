{ pkgs, ... }: {
  home.packages = [
    pkgs.unstable.zed-editor
  ];

  # add in settings.json
}
