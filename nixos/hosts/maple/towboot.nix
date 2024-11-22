{ pkgs, ... }:
let
  towboot = pkgs.fetchzip {
    url = "https://github.com/Tow-Boot/Tow-Boot/releases/download/release-2023.07-007/pine64-rockpro64-2023.07-007.tar.xz";
    hash = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
  };
in
towboot
