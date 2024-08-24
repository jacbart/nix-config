{ config, desktop, hostname, lib, pkgs, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [ ]
  ++ lib.optionals (desktop != null) [
    ../../desktop/${desktop}.nix
    ../../desktop/${desktop}-apps.nix
    ../../desktop/vscode.nix
  ];

  environment.systemPackages = with pkgs; [
    age
  ] ++ lib.optionals (desktop != null) [
    gimp-with-plugins
    zoom-us

    # Fast moving apps use the unstable branch
    unstable.discord
    unstable.google-chrome
    unstable.slack
    unstable.firefox-unwrapped
  ];

  users.users.meep = {
    description = "Meep";
    extraGroups = [
      "audio"
      "input"
      "networkmanager"
      "users"
      "video"
      "wheel"
    ]
    ++ ifExists [
      "docker"
      "podman"
    ];
    # mkpasswd -m sha-512
    hashedPassword = "$6$d0rN6VEKockAdT6T$tAGvh9b1W0TAW.I0V/tGNomPlQs8DdNvWQCtTiX8bil7fWyIherdRoM58yRy/yPTIZbajBobWvDTKNQR14H.P.";
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1ssGFun8as4ZCOCHz8lAWHwqbcqBDdj12Z56aHgEdb jack bartlett"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIF4nyZ9WdHRf6yy6IlB/qJbNLIf3Sp9umUjm1pHhIAvAAAABHNzaDo= jacbart@gmail.com"
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.zsh;
  };
}
