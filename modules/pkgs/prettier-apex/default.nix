{
  lib,
  buildNpmPackage,
}:
buildNpmPackage {
  pname = "prettier-apex";
  version = "2.3.0";

  src = ./.;

  npmDepsHash = "sha256-MY5vzptN0ye3o4OtHJ1b6jQrqU/kyAUte5gg1BV8i1w=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/prettier-apex
    cp -r node_modules $out/lib/prettier-apex/
    cp package.json $out/lib/prettier-apex/

    # Wrapper that runs prettier with the Apex plugin
    cat > $out/bin/prettier-apex <<'SCRIPT'
    #!/usr/bin/env sh
    exec "$(dirname "$0")/../lib/prettier-apex/node_modules/.bin/prettier" --plugin=prettier-plugin-apex "$@"
    SCRIPT
    chmod +x $out/bin/prettier-apex

    runHook postInstall
  '';

  meta = with lib; {
    description = "Prettier with @salesforce/prettier-plugin-apex for Apex formatting";
    homepage = "https://github.com/dangmai/prettier-plugin-apex";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
