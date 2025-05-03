{ config
, desktop
, hostname
, inputs
, lib
, outputs
, pkgs
, stateVersion
, username
, ...
}:
let
  inherit (pkgs.stdenv) isDarwin;
in
{
  # Only import desktop configuration if the host is desktop enabled
  # Only import user specific configuration if they have bespoke settings
  imports =
    [
      # Or modules exported from other flakes (such as nix-colors):
      inputs.sops-nix.homeManagerModules.sops

      # You can also split up your configuration and import pieces of it here:
      ./core
      ./shell
    ]
    ++ lib.optional (builtins.isPath (./. + "/users/${username}")) ./users/${username}
    ++ lib.optional (builtins.pathExists (./. + "/users/${username}/hosts/${hostname}.nix")) ./users/${username}/hosts/${hostname}.nix
    ++ lib.optional (desktop != null) ./desktop;

  home = {
    activation.report-changes = config.lib.dag.entryAnywhere ''
      ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
    '';
    homeDirectory =
      if isDarwin
      then "/Users/${username}"
      else "/home/${username}";
    sessionPath = [ "$HOME/.local/bin" ];
    inherit stateVersion;
    inherit username;
  };

  # Workaround home-manager bug with flakes
  # - https://github.com/nix-community/home-manager/issues/2033
  news.display = "silent";

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.local-packages
      outputs.overlays.script-packages
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  nix =
    if isDarwin
    then { }
    else {
      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

      package = pkgs.lix;
      settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
        # Avoid unwanted garbage collection when using nix-direnv
        keep-outputs = true;
        keep-derivations = true;
        warn-dirty = false;
      };
    };
}
