{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_15,
  darwinMinVersionHook,
}:

stdenv.mkDerivation rec {
  pname = "cornerfix";
  version = "0-unstable-2026-04-13";

  src = fetchFromGitHub {
    owner = "makalin";
    repo = "CornerFix";
    rev = "e8320ed5fd925edf113417cb1810dbea514636d8";
    hash = "sha256-x0N7834Tuho8GL3ruKlW3HPJbSOXAMNPzsIdeToai+s=";
  };

  patches = [ ./inject-dylib-relative-path.patch ];

  # ScreenCaptureKit needs macOS 12.3+ SDK; legacy darwin.apple_sdk.* stubs removed in nixpkgs 25.11
  buildInputs = [
    apple-sdk_15
    (darwinMinVersionHook "12.3")
  ];

  buildPhase = ''
    runHook preBuild
    make dylib cli inject
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/cornerfix $out/bin $out/share/cornerfix/examples
    install -m 755 build/libcornerfix.dylib $out/lib/cornerfix/
    install -m 755 build/cornerfixctl $out/bin/
    install -m 755 build/cornerfix-inject $out/bin/
    install -m 644 libcornerfix.dylib.blacklist $out/share/cornerfix/
    install -m 644 README.md CLI.md LOADER.md COMPATIBILITY.md TESTING.md $out/share/cornerfix/
    shopt -s nullglob
    for f in examples/*.sh; do
      install -m 755 "$f" $out/share/cornerfix/examples/
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "Injected macOS window sharpener (libcornerfix.dylib + cornerfixctl)";
    homepage = "https://github.com/makalin/CornerFix";
    license = licenses.mit;
    platforms = platforms.darwin;
    mainProgram = "cornerfixctl";
  };
}
