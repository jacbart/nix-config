{ pkgs, ... }:
let
  name = builtins.baseNameOf (builtins.toString ./.);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = with pkgs; [
    dasel
    coreutils
  ];
  # The script embeds dasel v3 query strings (e.g. '$root["..."]') in bash
  # single quotes so bash does NOT expand them — dasel does. SC2016 (info)
  # flags that as "you probably meant double quotes"; here it is intentional.
  excludeShellChecks = [ "SC2016" ];
  text = builtins.readFile ./${name}.sh;
}
