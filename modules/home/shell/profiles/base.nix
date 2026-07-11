{
  pkgs,
  platform,
  lib,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux;
  keyPath = "~/.ssh/id_ratatoskr";
  sshHosts = [
    {
      name = "ash";
      user = "meep";
      inherit keyPath;
    }
    {
      name = "boojum";
      user = "meep";
      inherit keyPath;
    }
    {
      name = "cork";
      user = "meep";
      inherit keyPath;
    }
    {
      name = "maple";
      user = "ratatoskr";
      inherit keyPath;
    }
    {
      name = "mesquite";
      user = "ratatoskr";
      inherit keyPath;
    }
    {
      name = "oak";
      user = "root";
      keyPath = "~/.ssh/id_do";
    }
    {
      name = "sycamore";
      user = "jackbartlett";
      inherit keyPath;
    }
    {
      name = "unicron";
      user = "jack";
      inherit keyPath;
    }
  ];
  mkSshHost = sshHost: {
    HostName = sshHost.name;
    User = sshHost.user;
    SetEnv = {
      TERM = "xterm-256color";
    };
    IdentityFile = sshHost.keyPath;
    ControlMaster = "auto";
    ControlPath = "~/.ssh/mux-%r@%h:%p";
    ControlPersist = "10";
  };
in
{
  imports = [
    ../tools/nodejs-hardening.nix
    ../tools/rust-hardening.nix
    ../tools/python-hardening.nix
    ../tools/go-hardening.nix
  ];

  home.packages =
    with pkgs;
    [
      scripts.journal
      scripts.resolve
      inputs.nix-diff.packages.${platform}.default
    ]
    ++ lib.optional isLinux pkgs.pax-utils;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings =
      (builtins.listToAttrs (
        map (sshHost: {
          name = sshHost.name;
          value = mkSshHost sshHost;
        }) sshHosts
      ))
      // {
        "got.bbl.systems" = {
          HostName = "got.bbl.systems";
          User = "jack";
          IdentityFile = "~/.ssh/id_ratatoskr";
          IdentitiesOnly = true;
        };
        "got.meep.sh" = {
          HostName = "got.meep.sh";
          User = "git";
          IdentityFile = "~/.ssh/id_ratatoskr";
          IdentitiesOnly = true;
        };
        "github.com" = {
          HostName = "github.com";
          User = "jacbart";
          IdentityFile = "~/.ssh/id_git";
          IdentitiesOnly = true;
        };
      };
  };
}
