# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  local-packages = final: _prev: import ../pkgs { pkgs = final; };
  script-packages = final: _prev: {
    scripts = import ../scripts { pkgs = final; };
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: _prev: { };

  uconsole-mods = _final: prev: {
    # needed for raspberry pi
    makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
    # retroarch controls
    retroarch-joypad-autoconfig = prev.retroarch-joypad-autoconfig.overrideAttrs {
      src = prev.fetchFromGitHub {
        owner = "jacbart";
        repo = "retroarch-joypad-autoconfig";
        rev = "7733b32317046ac0e4a2897f45fb1c9844986190";
        hash = "sha256-j7Cu66PU+mY3c6ojTmdYPKZlUMbL9L4xoyJP4gQaLqU=";
      };
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
