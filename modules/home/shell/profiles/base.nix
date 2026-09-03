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
  # HostName resolves via the fleet's public DNS records (tailscale-derived,
  # see vars.dns) — deterministic everywhere, no MagicDNS dependency.
  sshHosts = [
    {
      name = "ash";
      hostName = "ash.meep.sh";
      user = "meep";
      inherit keyPath;
    }
    {
      name = "boojum";
      hostName = "boojum.meep.sh";
      user = "meep";
      inherit keyPath;
    }
    {
      name = "cork";
      hostName = "cork.meep.sh";
      user = "meep";
      inherit keyPath;
    }
    {
      name = "maple";
      hostName = "maple.meep.sh";
      user = "ratatoskr";
      inherit keyPath;
    }
    {
      # Not on the tailnet; reachable only from its own LAN.
      name = "mesquite";
      hostName = "10.120.0.1";
      user = "ratatoskr";
      inherit keyPath;
    }
    {
      name = "oak";
      hostName = "oak.meep.sh";
      port = 3048;
      user = "root";
      keyPath = "~/.ssh/id_do";
    }
    {
      name = "sycamore";
      hostName = "sycamore.meep.sh";
      user = "jackbartlett";
      inherit keyPath;
    }
    {
      name = "unicron";
      hostName = "unicron.meep.sh";
      user = "jack";
      inherit keyPath;
    }
  ];
  mkSshHost = sshHost: {
    HostName = sshHost.hostName or sshHost.name;
    User = sshHost.user;
    Port = toString (sshHost.port or 22);
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
      go-task # Taskfile-driven flake update gating (Taskfile.yml at repo root)
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
