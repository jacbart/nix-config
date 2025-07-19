{
  lib,
  pkgs,
  stdenv,
  bun,
  makeWrapper,
  ...
}:
stdenv.mkDerivation rec {
  pname = "libro";
  version = "1.0.0";
  src = pkgs.fetchFromGitHub {
    repo = "libro-client";
    owner = "jedwards1230";
    rev = "6ee87ab3b3dc76d781da90cb4577fa141c4c5094";
    hash = "sha256-jloyUYZ7k/SzXHjF6Jx0wBzj5jInpiEO+j/lniRz3Gw=";
  };

  nativeBuildInputs = [
    bun
    makeWrapper
  ];

  patchPhase = ''
    # replace line 4 with env var LIBROFM_DIR instead of project dir
    sed -i '4s/.*/const PROJECT_DIR = process\.env\.LIBROFM_DIR/' ./src/lib/Directories.ts
  '';

  buildPhase = ''
    ${lib.getExe bun} install
  '';

  installPhase = ''
    mkdir -p $out/{bin,src}
    cp -r . $out/src
    makeWrapper ${lib.getExe bun} $out/bin/libro \
        --chdir $out/src \
        --set NODE_ENV production \
        --add-flags run \
        --add-flags cli.ts
    makeWrapper ${lib.getExe bun} $out/bin/librod \
        --chdir $out/src \
        --set NODE_ENV production \
        --add-flags run \
        --add-flags service.ts
  '';

  meta = {
    mainProgram = pname;
    decription = "Library for downloading Libro.fm audiobooks";
    homepage = "https://github.com/jedwards1230/libro-client";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jacbart ];
  };
}
