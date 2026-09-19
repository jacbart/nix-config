{
  pkgs,
  ...
}:
{
  home.packages =
    let
      opencode = pkgs.unstable.opencode.overrideAttrs (
        final: prev: {
          postPatch = prev.postPatch + ''
            # fix for bun 1.4.x code splitting
            substituteInPlace packages/opencode/script/build.ts \
              --replace-fail 'splitting: true,' 'splitting: false,'
          '';
        }
      );
    in
    [ opencode ];
  # home.packages = with pkgs; [

  #   unstable.opencode
  #   unstable.skills
  # ];
}
