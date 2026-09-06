{ inputs, ... }:
{
  flake.overlays = {
    # Custom packages from the 'pkgs' directory (use prev, not final — final would recurse via self-reference)
    local-packages =
      _final: prev:
      import ../pkgs {
        pkgs = prev;
        inherit inputs;
      };
    script-packages = final: _prev: {
      scripts = import ../scripts { pkgs = final; };
    };

    # https://nixos.wiki/wiki/Overlays
    modifications = final: prev: {
      inherit (final.lixPackageSets.stable)
        nix-eval-jobs
        ;
      # Python 3.13 argparse quotes choices in error messages, breaking
      # commitizen 4.13.9's regression fixture for test_invalid_command.
      commitizen = prev.commitizen.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [
          "test_invalid_command"
        ];
      });
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
    unstable-packages =
      final: _prev:
      let
        unstablePkgs = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [ "electron-39.8.10" ];
          };
        };
      in
      {
        unstable = unstablePkgs // {
          # Default vivaldi build omits ffmpeg blob; upstream binary still dlopen()'s libffmpeg.so → startup fail.
          vivaldi = unstablePkgs.vivaldi.override { proprietaryCodecs = true; };
        };
      };
  };
}
