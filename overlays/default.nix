# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  local-packages = final: _prev: import ../pkgs { pkgs = final; };
  script-packages = final: _prev: {
    scripts = import ../scripts { pkgs = final; };
  };

  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    inherit (final.lixPackageSets.latest)
      nixpkgs-review
      # nix-direnv
      nix-eval-jobs
      nix-fast-build
      colmena
      ;
    inetutils = prev.inetutils.overrideAttrs (oldAttrs: rec {
      version = "2.6";
      src = prev.fetchurl {
        url = "mirror://gnu/inetutils/inetutils-${version}.tar.xz";
        hash = "sha256-aL7b/q9z99hr4qfZm8+9QJPYKfUncIk5Ga4XTAsjV8o=";
      };
    });
  };

  uconsole-mods = final: prev: {
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
    squeekboard = prev.squeekboard.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        rm $out/bin/squeekboard
        touch $out/bin/squeekboard
      '';
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
    };
  };
}
