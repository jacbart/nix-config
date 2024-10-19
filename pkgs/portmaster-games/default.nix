{ pkgs
, lib }:
pkgs.stdenv.mkDerivation rec {
    pname = "PortMaster";
    version = "2024.10.16-1432";

    src = pkgs.fetchzip {
        url = "https://github.com/PortsMaster/PortMaster-GUI/releases/download/${version}/${pname}.zip";
        sha256 = "sha256-aB/xEQNWqdWaj75+sxEx6bbPHhELpwu7tl1ac1gpayI=";
    };

    nativeBuildInputs = [ pkgs.gnused ];

    buildInputs = with pkgs; [
        python3
        python311Packages.ansimarkup
        python311Packages.certifi
        python311Packages.colorama
        python311Packages.fastjsonschema
        python311Packages.idna
        python311Packages.loguru
        python311Packages.pysdl2
        python311Packages.pypng
        python311Packages.pyqrcode
        python311Packages.requests
        python311Packages.typing-extensions
        python311Packages.urllib3
    ];

    buildPhase = ''
        sed -i 's|#!/bin/bash|#!/usr/bin/env bash|' PortMaster.sh
        sed -i "s|controlfolder=\"/roms/ports/PortMaster\"|controlfolder=\"$out/PortMaster\"|" PortMaster.sh
        sed -i "s|controlfolder=\"/\$directory/ports/PortMaster\"|controlfolder=\"$out/PortMaster\"|" control.txt
    '';

    installPhase = ''
        mkdir -p $out/bin
        cd ..
        cp -r source $out/PortMaster
        ln -s $out/PortMaster/PortMaster.sh $out/bin/pmg
    '';

    meta = with lib; {
        description = "Designed to facilitate downloading and installation of ports for handheld devices";
        homepage = "https://github.com/PortsMaster/PortMaster-GUI";
        license = licenses.mit;
        maintainers = with maintainers; [ jacbart ];
        mainProgram = "pmg";
    };
}
