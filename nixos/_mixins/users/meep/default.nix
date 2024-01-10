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
    gnome.gnome-clocks
    libreoffice
    pick-colour-picker
    zoom-us

    # Fast moving apps use the unstable branch
    unstable.discord
    unstable.google-chrome
    unstable.slack
    unstable.firefox-unwrapped
  ];

  services = {
    aria2 = {
      enable = true;
      openPorts = true;
      rpcSecret = "${hostname}";
    };
    croc = {
      enable = true;
      pass = "${hostname}";
      openFirewall = true;
    };
  };

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
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.zsh;
  };
}
