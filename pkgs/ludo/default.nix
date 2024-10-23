{ lib, buildGo123Module, fetchFromGitHub, pkg-config, openal, gcc, glfw3, libGL, mesa, xorg }:

buildGo123Module rec {
    pname = "ludo";
    version = "0.17.2";

    src = fetchFromGitHub {
        owner = "libretro";
        repo = "ludo";
        rev = "v${version}";
        sha256 = "sha256-ED+Mh4xyPXl4jH8evY85aTHmYWczCXiattpFrK66jMo=";
    };

    patches = [
        ./ludo.patch
    ];

    vendorHash = null;

    nativeBuildInputs = [ pkg-config mesa ];
    buildInputs = [
        openal
        gcc
        glfw3
        libGL
        mesa
        xorg.libX11 xorg.libXcursor xorg.libXrandr xorg.libXinerama xorg.libXi xorg.libXxf86vm
    ];

    meta = with lib; {
        description = "A libretro frontend written in Go";
        homepage = "https://ludo.libretro.com/";
        license = licenses.gpl3Plus;
        platforms = [ "x86_64-linux" "aarch64-linux" ];
        maintainers = with maintainers; [ jacbart ];
    };
}
