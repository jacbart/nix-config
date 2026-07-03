{
  lib,
  stdenv,
  fetchurl,
  unzip,
  makeWrapper,
  jdk21,
}:
let
  version = "67.3.0";
in
stdenv.mkDerivation {
  pname = "apex-jorje-lsp";
  inherit version;

  src = fetchurl {
    url = "https://salesforce.gallerycdn.vsassets.io/extensions/salesforce/salesforcedx-vscode-apex/${version}/1782860082071/Microsoft.VisualStudio.Services.VSIXPackage";
    sha256 = "e32808f75243bd6bed36bf246ddc4c214c533b806b565bd8693cf9a5375b6b7e";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  buildInputs = [ jdk21 ];

  unpackPhase = ''
    runHook preUnpack
    unzip -q $src -d vsix
    runHook postUnpack
  '';

  buildPhase = ''
    runHook preBuild
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib $out/bin
    cp vsix/extension/dist/apex-jorje-lsp.jar $out/lib/

    makeWrapper ${jdk21}/bin/java $out/bin/apex-lsp \
      --add-flags "-cp $out/lib/apex-jorje-lsp.jar" \
      --add-flags "apex.jorje.lsp.ApexLanguageServerLauncher" \
      --add-flags "-Dlwc.typegeneration.disabled=true" \
      --add-flags "-Dtrace.protocol=false"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Apex Language Server (apex-jorje-lsp) from Salesforce VS Code extension";
    homepage = "https://github.com/forcedotcom/salesforcedx-vscode";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
