{
  config,
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      nil
      nixfmt-rfc-style
    ];

    sessionVariables = {
      EDITOR = "hx";
      SYSTEMD_EDITOR = "hx";
      VISUAL = "hx";
    };
  };

  programs.helix = {
    enable = true;
    package = pkgs.unstable.helix;
  };
}
