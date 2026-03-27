{
  lib,
  config,
  inputs,
  vars,
  stateVersion,
  ...
}:
let
  # Helper type for module registries
  deferredModuleType = lib.types.deferredModule;
in
{
  options = {
    # Host configuration registries
    nixosHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              modules = lib.mkOption {
                type = lib.types.listOf deferredModuleType;
                default = [ ];
                description = "List of NixOS modules for this host";
              };
              system = lib.mkOption {
                type = lib.types.str;
                default = "x86_64-linux";
                description = "System architecture for this host";
              };
              username = lib.mkOption {
                type = lib.types.str;
                default = "root";
                description = "Primary username for this host";
              };
              desktop = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Desktop environment for this host";
              };
            };
            config = { };
          }
        )
      );
      default = { };
      description = "NixOS host configurations registry";
    };

    darwinHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              modules = lib.mkOption {
                type = lib.types.listOf deferredModuleType;
                default = [ ];
                description = "List of Darwin modules for this host";
              };
              username = lib.mkOption {
                type = lib.types.str;
                description = "Primary username for this Darwin host";
              };
            };
            config = { };
          }
        )
      );
      default = { };
      description = "Darwin host configurations registry";
    };

    homeHosts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            modules = lib.mkOption {
              type = lib.types.listOf deferredModuleType;
              default = [ ];
              description = "List of Home-Manager modules for this host";
            };
            system = lib.mkOption {
              type = lib.types.str;
              default = "x86_64-linux";
              description = "System architecture for this home configuration";
            };
          };
        }
      );
      default = { };
      description = "Home-Manager configurations registry";
    };
  };

  config = {
    # Build NixOS configurations from registry
    flake.nixosConfigurations = lib.flip lib.mapAttrs config.nixosHosts (
      _name: cfg:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            vars
            stateVersion
            ;
          hostname = _name;
          platform = cfg.system;
          username = cfg.username;
          desktop = cfg.desktop;
          outputs = config.flake;
          inherit (config.flake) overlays;
        };
        modules =
          cfg.modules
          ++ [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            ./nixos/services/openssh.nix
            {
              networking.hostName = _name;
              nixpkgs.hostPlatform = cfg.system;
            }
          ]
          ++ lib.optional (builtins.pathExists ./nixos/users/${cfg.username}) ./nixos/users/${cfg.username};
      }
    );

    # Build Darwin configurations from registry
    flake.darwinConfigurations = lib.flip lib.mapAttrs config.darwinHosts (
      _name: cfg:
      inputs.nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit
            inputs
            vars
            stateVersion
            ;
          inherit (config.flake) overlays;
          username = cfg.username;
        };
        modules = cfg.modules ++ [
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      }
    );

    # Build Home-Manager configurations from registry
    flake.homeConfigurations = lib.flip lib.mapAttrs config.homeHosts (
      name: cfg:
      let
        parts = lib.splitString "@" name;
        username = builtins.elemAt parts 0;
        hostname = builtins.elemAt parts 1;
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages.${cfg.system};
        extraSpecialArgs = {
          inherit
            inputs
            vars
            stateVersion
            username
            hostname
            ;
          platform = cfg.system;
          inherit (config.flake) overlays;
        };
        modules = cfg.modules ++ [
          inputs.sops-nix.homeManagerModules.sops
        ];
      }
    );
  };
}
