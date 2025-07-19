{
  pkgs,
  lib,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "PortMaster";
  version = "2024.10.16-1432";

  src = pkgs.fetchzip {
    url = "https://github.com/PortsMaster/PortMaster-GUI/releases/download/${version}/${pname}.zip";
    sha256 = "sha256-aB/xEQNWqdWaj75+sxEx6bbPHhELpwu7tl1ac1gpayI=";
  };

  nativeBuildInputs = [
    pkgs.gnused
    pkgs.gnutar
    pkgs.unzip
  ];

  buildInputs = [
    pkgs.coreutils-full
    pkgs.python3
    pkgs.SDL2_ttf
    # pkgs.SDL2_image
    # pkgs.SDL2_gfx
    # pkgs.SDL2_mixer
    # pkgs.python311Packages.ansimarkup
    # pkgs.python311Packages.certifi
    # pkgs.python311Packages.colorama
    # pkgs.python311Packages.types-colorama
    # pkgs.python311Packages.fastjsonschema
    # pkgs.python311Packages.idna
    # pkgs.python311Packages.loguru
    pkgs.python311Packages.pysdl2
    # pkgs.python311Packages.pypng
    # pkgs.python311Packages.pyqrcode
    # pkgs.python311Packages.requests
    # pkgs.python311Packages.typing-extensions
    # pkgs.python311Packages.urllib3
  ];

  buildPhase = ''
    # update PortMaster.sh
    # sed -i "s|controlfolder=\"/roms/ports/PortMaster\"|controlfolder=\"$out/PortMaster\"|" PortMaster.sh
    sed -i "s|\$ESUDO chmod -R +x .||" PortMaster.sh
    # sed -i 's|export PYSDL2_DLL_PATH="/usr/lib"|export PYSDL2_DLL_PATH="${pkgs.python311Packages.pysdl2}/lib/python3.11/site-packages/sdl2"|' PortMaster.sh
    sed -i 's|export PYSDL2_DLL_PATH="/usr/lib"||' PortMaster.sh
    # update context.txt
    sed -i "s|controlfolder=\"/\$directory/ports/PortMaster\"|controlfolder=\"$out/PortMaster\"|" control.txt

    mkdir /roms

    # extract exlibs and pylibs
    unzip pylibs.zip
    rm pylibs.zip

    tar -C "./pylibs/resources" -xf "./pylibs/resources/NotoSans.tar.xz"
    rm -f ./pylibs/resources/NotoSans.tar.xz

    cp -f ./pylibs/resources/*.ttf ./resources/
    rm -f ./resources/do_init

    if [ ! -d "/dev/shm/portmaster" ]; then
      mkdir /dev/shm/portmaster
    else
      rm -f /dev/shm/portmaster/pm_*
    fi
  '';

  installPhase = ''
    mkdir -p $out/bin
    cd ..
    cp -r source $out/PortMaster
    ln -s $out/PortMaster/PortMaster.sh $out/bin/pmg
    chmod -R +x .
  '';

  meta = with lib; {
    description = "Designed to facilitate downloading and installation of ports for handheld devices";
    homepage = "https://github.com/PortsMaster/PortMaster-GUI";
    license = licenses.mit;
    maintainers = with maintainers; [ jacbart ];
    mainProgram = "pmg";
  };
}
