{
  lib,
  SDL2,
  SDL2_mixer,
  SDL2_image,
  callPackage,
  cmake,
  pkg-config,
  ninja,
  fetchFromGitHub,
  libpng,
  libjpeg,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nxengine-evo";
  version = "2.6.5-1";

  src = fetchFromGitHub {
    owner = "nxengine";
    repo = "nxengine-evo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UufvtfottD9DrnjN9xhAlkNdW5Ha+vZwf/4uKDtF5ho=";
  };

  nativeBuildInputs = [
    SDL2
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    SDL2_image
    libpng
    libjpeg
  ];

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    cd ..
    mkdir -p $out/bin/ $out/share/nxengine/
    install bin/* $out/bin/
  '' + ''
    cp -r ${finalAttrs.finalPackage.assets}/share/nxengine/data $out/share/nxengine/data
    chmod -R a=r,a+X $out/share/nxengine/data
  '' + ''
    runHook postInstall
  '';

  passthru = {
    assets = callPackage ./assets.nix { };
  };

  meta = {
    homepage = "https://github.com/nxengine/nxengine-evo";
    changelog = "https://github.com/nxengine/nxengine-evo/releases/tag/${finalAttrs.src.rev}";
    description = "Complete open-source clone/rewrite of the masterpiece jump-and-run platformer Doukutsu Monogatari (also known as Cave Story)";
    license = with lib.licenses; [
      gpl3Plus
    ];
    mainProgram = "nx";
    maintainers = with lib.maintainers; [ AndersonTorres ];
    platforms = lib.platforms.linux;
  };
})
