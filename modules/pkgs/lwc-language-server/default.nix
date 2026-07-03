{
  lib,
  buildNpmPackage,
  fetchurl,
}:
buildNpmPackage {
  pname = "lwc-language-server";
  version = "4.12.13";

  src = fetchurl {
    url = "https://registry.npmjs.org/@salesforce/lwc-language-server/-/lwc-language-server-4.12.13.tgz";
    sha256 = "711f93a626a0fe1495bc6ab25fb09cd9f141e5949d366f9fc893ab1a03883e4a";
  };

  npmDepsHash = "sha256-iWjDSPNG53gevy5Oyv/LXSu4JdIMf1NBJJBpWBIRhy8=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmBuildScript = "build";

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/lwc-language-server

    # Copy the entire package — use a namespaced dir to avoid buildEnv conflicts
    # with other node-based packages (e.g. prettier-apex) that also have node_modules/.
    cp -r bin $out/lib/lwc-language-server/
    cp -r lib $out/lib/lwc-language-server/ 2>/dev/null || true
    cp -r dist $out/lib/lwc-language-server/ 2>/dev/null || true
    cp -r src $out/lib/lwc-language-server/ 2>/dev/null || true
    cp -r node_modules $out/lib/lwc-language-server/
    cp package.json $out/lib/lwc-language-server/

    # Symlink the bin entry point
    ln -s $out/lib/lwc-language-server/bin/lwc-language-server.js $out/bin/lwc-language-server
    patchShebangs $out/lib/lwc-language-server/bin/lwc-language-server.js

    runHook postInstall
  '';

  meta = with lib; {
    description = "LWC Language Server for Lightning Web Components";
    homepage = "https://github.com/forcedotcom/lightning-language-server";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
