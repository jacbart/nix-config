{ config, desktop, username, lib, pkgs, ... }:
let
  # inherit (pkgs.stdenv) isDarwin;
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  # homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
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

  sops.secrets.meep-password.neededForUsers = true;
  users.mutableUsers = false;

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
    hashedPasswordFile = config.sops.secrets.meep-password.path;
    homeMode = "0755";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1ssGFun8as4ZCOCHz8lAWHwqbcqBDdj12Z56aHgEdb jack bartlett"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJJt5PF37jNBpEIan2WXnN23fNiZ2ApC5RxCSXrcNZddAAAABHNzaDo= ratatoskr"
    ];
    packages = [ pkgs.home-manager ];
    shell = pkgs.zsh;
  };

  nix.settings.trusted-users = [ "meep" ];
}
