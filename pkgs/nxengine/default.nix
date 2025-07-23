{
  lib,
  SDL2,
  SDL2_mixer,
  SDL2_image,
  SDL2_ttf,
  SDL2_gfx,
  SDL2_net,
  callPackage,
  cmake,
  libcxx,
  pkg-config,
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

  patches = [
    # Fix missing cstdint include
    # add missing uconsole resolution
    ./uconsole.patch
  ];

  nativeBuildInputs = [
    SDL2
    cmake
    libcxx
    pkg-config
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    SDL2_image
    SDL2_ttf
    SDL2_gfx
    SDL2_net
    libpng
    libjpeg
  ];

  strictDeps = true;

  buildPhase = ''
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make
    cd ..
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin/ $out/share/nxengine/
  ''
  + ''
    cp -r ${finalAttrs.finalPackage.assets}/share/nxengine/data $out/share/nxengine/
    chmod -R a=r,a+X $out/share/nxengine/data
  ''
  + ''
    cp ./build/nxengine-evo $out/bin/
    ln -s $out/bin/nxengine-evo $out/bin/nx

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
