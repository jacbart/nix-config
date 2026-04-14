{ inputs, ... }:
{
  flake.overlays = {
    # Custom packages from the 'pkgs' directory (use prev, not final — final would recurse via self-reference)
    local-packages = _final: prev: import ../pkgs { pkgs = prev; };
    script-packages = _final: prev: {
      scripts = import ../scripts { pkgs = prev; };
    };

    # https://nixos.wiki/wiki/Overlays
    modifications = final: _prev: {
      inherit (final.lixPackageSets.latest)
        nix-eval-jobs
        ;
    };

    uconsole-mods = final: prev: {
      makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });
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

    # Unstable nixpkgs accessible through 'pkgs.unstable'
    unstable-packages = final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    };
  };
}
