{
  pkgs,
  config,
  ...
}:
{
  home.sessionVariables = {
    GOTOOLCHAIN = "local";
    GOFLAGS = "-mod=readonly";
  };

  home.packages = with pkgs; [
    govulncheck
  ];
}
