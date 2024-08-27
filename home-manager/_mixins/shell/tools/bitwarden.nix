{ pkgs, ... }: {
  home.packages = with pkgs; [
    bitwarden-cli # password manager cli
    bws # secret manager cli
  ];
}
