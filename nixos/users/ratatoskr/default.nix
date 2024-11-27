{ config
, desktop
, lib
, pkgs
, ...
}:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports =
    lib.optionals (desktop != null) [
    ];

  environment.systemPackages = with pkgs;
    [
      age
    ]
    ++ lib.optionals (desktop != null) [
      unstable.firefox
    ];

  sops.secrets.ratatoskr-password.neededForUsers = true;
  users.mutableUsers = false;

  users.users.ratatoskr = {
    description = "Ratatoskr";
    extraGroups =
      [
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
        "nextcloud"
        "hydra"
      ];
    hashedPasswordFile = config.sops.secrets.ratatoskr-password.path;
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1ssGFun8as4ZCOCHz8lAWHwqbcqBDdj12Z56aHgEdb jack bartlett"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJJt5PF37jNBpEIan2WXnN23fNiZ2ApC5RxCSXrcNZddAAAABHNzaDo= ratatoskr"
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.nushell;
  };

  nix.settings.trusted-users = [ "ratatoskr" ];
}
