{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mcp-nixos
  ];
}
