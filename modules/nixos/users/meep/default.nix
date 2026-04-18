{
  config,
  lib,
  pkgs,
  ...
}:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  environment.systemPackages = [
    pkgs.age
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

  # Must match HM `SSH_AUTH_SOCK=%t/ssh-agent`; do not rely on mkDefault if another module flips it.
  programs.ssh.startAgent = lib.mkForce true;

  # Same 1h lifetime as old `ssh-agent -t 3600`; keys dropped from agent after that.
  programs.ssh.agentTimeout = lib.mkDefault "3600";
}
